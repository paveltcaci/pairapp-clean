import { onCall } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { Errors } from "../../utils/errors";
import { parseOrThrow, joinCoupleSchema } from "../../utils/validation";
import { CoupleDoc, UserDoc } from "../../types";
import { sendPushToUser } from "../../utils/push";

/**
 * joinCoupleByInviteCode (раздел 6.1, 6.2, 18 ТЗ).
 *
 * Раздел 6.2: "Код можно использовать только один раз: после подключения
 * партнёра код деактивируется. При попытке использовать уже использованный
 * код — показывается сообщение об ошибке."
 * Раздел 6.3: "Один пользователь — одна активная пара", "В паре —
 * максимум два партнёра".
 */
export const joinCoupleByInviteCode = onCall<{ inviteCode: string }>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(joinCoupleSchema, request.data);
    const normalizedCode = input.inviteCode.trim().toUpperCase();

    const userRef = db.collection(Collections.users).doc(uid);
    const userSnap = await userRef.get();
    if (!userSnap.exists) {
      throw Errors.notFound("Профиль пользователя");
    }
    const user = userSnap.data() as UserDoc;

    if (user.currentCoupleId) {
      const existingCoupleSnap = await db
        .collection(Collections.couples)
        .doc(user.currentCoupleId)
        .get();
      const existingCouple = existingCoupleSnap.data() as CoupleDoc | undefined;
      if (existingCouple && existingCouple.status === "active") {
        throw Errors.failedPrecondition(
          "У вас уже есть активная пара. Сначала выйдите из текущей."
        );
      }
    }

    const coupleQuery = await db
      .collection(Collections.couples)
      .where("inviteCode", "==", normalizedCode)
      .limit(1)
      .get();

    if (coupleQuery.empty) {
      throw Errors.notFound("Пара с таким invite-кодом");
    }

    const coupleRef = coupleQuery.docs[0].ref;

    const result = await db.runTransaction(async (tx) => {
      const coupleSnap = await tx.get(coupleRef);
      const couple = coupleSnap.data() as CoupleDoc;

      if (couple.inviteCodeUsed) {
        throw Errors.failedPrecondition(
          "Этот invite-код уже использован."
        );
      }
      if (couple.status !== "active") {
        throw Errors.failedPrecondition("Эта пара недоступна для подключения.");
      }
      if (couple.partnerAId === uid) {
        throw Errors.invalidArgument("Невозможно подключиться к своей же паре.");
      }
      if (couple.partnerBId) {
        // Защитный случай: partnerBId уже заполнен, но inviteCodeUsed
        // почему-то false — не должно происходить, но не доверяем одному флагу.
        throw Errors.failedPrecondition("В этой паре уже два партнёра.");
      }

      tx.update(coupleRef, {
        partnerBId: uid,
        inviteCodeUsed: true,
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.update(userRef, {
        currentCoupleId: coupleRef.id,
        updatedAt: FieldValue.serverTimestamp(),
      });

      return { coupleId: coupleRef.id, partnerAId: couple.partnerAId };
    });

    // Раздел 14 ТЗ не выделяет это отдельной строкой таблицы, но первый
    // партнёр должен узнать о подключении второго (см. NotificationSettings.partnerJoined).
    await sendPushToUser(result.partnerAId, "partnerJoined", {
      titleKey: "push.partnerJoined.title",
      bodyKey: "push.partnerJoined.body",
    }).catch(() => undefined);

    return { coupleId: result.coupleId };
  }
);
