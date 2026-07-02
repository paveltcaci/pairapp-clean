import { onCall } from "firebase-functions/v2/https";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { Collections, db } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { resolvePartner } from "../../utils/couple-context";
import { sendPushToUser } from "../../utils/push";
import { Errors } from "../../utils/errors";
import { CoupleDoc, UserDoc } from "../../types";

/**
 * leaveCouple (раздел 6.1, 6.3, 18 ТЗ): "При выходе из пары второй
 * партнёр получает уведомление. После выхода пользователь может создать
 * новую пару."
 *
 * Пара переводится в disconnected, а не удаляется — история проблем и
 * договорённостей должна сохраниться для оставшегося партнёра (тот же
 * принцип, что и в deleteAccount).
 */
export const leaveCouple = onCall(async (request) => {
  const uid = requireAuth(request);
  const userRef = db.collection(Collections.users).doc(uid);
  const userSnap = await userRef.get();

  if (!userSnap.exists) {
    throw Errors.notFound("Профиль пользователя");
  }

  const user = userSnap.data() as UserDoc;
  const currentCoupleId = user.currentCoupleId;

  if (!currentCoupleId) {
    throw Errors.failedPrecondition(
      "У вас нет активной пары. Создайте пару или подключитесь по коду."
    );
  }

  const coupleRef = db.collection(Collections.couples).doc(currentCoupleId);
  const coupleSnap = await coupleRef.get();

  if (!coupleSnap.exists) {
    await userRef.update({
      currentCoupleId: null,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return { success: true };
  }

  const couple = coupleSnap.data() as CoupleDoc;
  resolvePartner(couple, uid);

  if (!["active", "blocked", "disconnected"].includes(couple.status)) {
    throw Errors.failedPrecondition(
      `Пара недоступна (статус: ${couple.status}).`
    );
  }

  let partnerId: string | null = null;
  let shouldNotifyPartner = false;

  await db.runTransaction(async (tx) => {
    const freshCoupleSnap = await tx.get(coupleRef);
    if (!freshCoupleSnap.exists) {
      tx.update(userRef, {
        currentCoupleId: null,
        updatedAt: FieldValue.serverTimestamp(),
      });
      return;
    }

    const freshCouple = freshCoupleSnap.data() as CoupleDoc;
    partnerId = resolvePartner(freshCouple, uid).partnerId;

    if (!["active", "blocked", "disconnected"].includes(freshCouple.status)) {
      throw Errors.failedPrecondition(
        `Пара недоступна (статус: ${freshCouple.status}).`
      );
    }

    if (freshCouple.status === "active" || freshCouple.status === "blocked") {
      shouldNotifyPartner = true;
      tx.update(coupleRef, {
        status: "disconnected",
        disconnectedAt: Timestamp.now(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    tx.update(db.collection(Collections.users).doc(uid), {
      currentCoupleId: null,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  if (shouldNotifyPartner && partnerId) {
    await sendPushToUser(partnerId, "partnerLeft", {
      titleKey: "push.partnerLeft.title",
      bodyKey: "push.partnerLeft.body",
    });
  }

  return { success: true };
});
