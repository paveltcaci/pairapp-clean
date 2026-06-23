import { onCall } from "firebase-functions/v2/https";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { db, Collections, auth } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { Errors } from "../../utils/errors";
import { CoupleDoc, UserDoc } from "../../types";
import { sendPushToUser } from "../../utils/push";
import { writeAuditLog } from "../../utils/audit-log";
import * as logger from "firebase-functions/logger";

/**
 * deleteAccount (раздел 18 ТЗ) — удаление аккаунта и данных пользователя.
 *
 * Раздел 15.3 ТЗ: "Пользователь подтверждает действие (двухшаговое).
 * Аккаунт удаляется, персональные данные удаляются или обезличиваются.
 * Партнёр получает уведомление о выходе. Пара переводится в статус
 * disconnected."
 *
 * Двухшаговое подтверждение реализуется на клиенте (два экрана/диалога
 * перед вызовом). Сюда долетает только финальный вызов, поэтому
 * параметр `confirm: true` обязателен как защита от случайного
 * вызова напрямую через консоль/дебаг.
 *
 * Подход к "удаляется или обезличивается" (раздел 15.3 ТЗ):
 * - Документ users НЕ удаляется физически, а обезличивается — потому что
 *   issues/issue_messages/agreements хранят authorId/proposedBy и т.п.,
 *   и полное удаление документа пользователя разорвало бы историю
 *   договорённостей партнёра (тот же принцип, что и "право на забвение"
 *   без разрушения чужих данных).
 * - Firebase Auth user удаляется физически — это и есть точка, после
 *   которой пользователь физически не может зайти в приложение.
 * - Email и displayName заменяются на плейсхолдеры, avatarUrl — на null,
 *   аватар в Storage удаляется отдельным шагом (storage trigger,
 *   за пределами этой функции — путь известен по userId).
 */
export const deleteAccount = onCall<{ confirm: boolean }>(async (request) => {
  const uid = requireAuth(request);

  if (request.data?.confirm !== true) {
    throw Errors.invalidArgument(
      "Удаление аккаунта требует явного подтверждения (confirm: true)."
    );
  }

  const userRef = db.collection(Collections.users).doc(uid);
  const userSnap = await userRef.get();
  if (!userSnap.exists) {
    throw Errors.notFound("Профиль пользователя");
  }
  const user = userSnap.data() as UserDoc;

  await db.runTransaction(async (tx) => {
    let coupleRef: FirebaseFirestore.DocumentReference | null = null;
    let couple: CoupleDoc | null = null;

    if (user.currentCoupleId) {
      coupleRef = db.collection(Collections.couples).doc(user.currentCoupleId);
      const coupleSnap = await tx.get(coupleRef);
      if (coupleSnap.exists) {
        couple = coupleSnap.data() as CoupleDoc;
      }
    }

    // Обезличивание профиля (раздел 15.3 ТЗ).
    tx.update(userRef, {
      email: `deleted-${uid}@deleted.pairapp.local`,
      displayName: "Удалённый пользователь",
      avatarUrl: null,
      fcmTokens: [],
      currentCoupleId: null,
      isDeleted: true,
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Пара переводится в disconnected (раздел 15.3 ТЗ), независимо от
    // того, был ли у пары второй партнёр.
    if (coupleRef && couple && couple.status === "active") {
      tx.update(coupleRef, {
        status: "disconnected",
        disconnectedAt: Timestamp.now(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  });

  // Уведомление оставшемуся партнёру (раздел 14 ТЗ: "Партнёр вышел из
  // пары" → "Оставшийся партнёр"). Выполняется после транзакции, т.к.
  // отправка push не должна быть частью атомарной записи в Firestore.
  if (user.currentCoupleId) {
    const coupleSnap = await db
      .collection(Collections.couples)
      .doc(user.currentCoupleId)
      .get();
    if (coupleSnap.exists) {
      const couple = coupleSnap.data() as CoupleDoc;
      const partnerId =
        couple.partnerAId === uid ? couple.partnerBId : couple.partnerAId;
      if (partnerId) {
        await sendPushToUser(partnerId, "partnerLeft", {
          titleKey: "push.partnerLeft.title",
          bodyKey: "push.partnerLeft.body",
        });
      }
    }
  }

  // Физическое удаление из Firebase Auth — точка отсечения доступа.
  try {
    await auth.deleteUser(uid);
  } catch (err) {
    logger.error(`Failed to delete auth user ${uid}`, err);
    // Профиль уже обезличен и доступ к паре отозван — не откатываем,
    // но сообщаем клиенту, что нужна повторная попытка финальной фазы.
    throw Errors.internal(
      "Данные обезличены, но удаление учётной записи авторизации не " +
        "завершилось. Повторите попытку или обратитесь в поддержку."
    );
  }

  logger.info(`Account ${uid} deleted and anonymized.`);
  await writeAuditLog({
    action: "account_deleted",
    actorId: uid,
    targetUserId: uid,
    targetCoupleId: user.currentCoupleId ?? null,
  });
  return { success: true };
});
