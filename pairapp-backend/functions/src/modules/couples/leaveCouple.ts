import { onCall } from "firebase-functions/v2/https";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { Collections, db } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { sendPushToUser } from "../../utils/push";

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
  const { couple, coupleRef } = await getActiveCoupleOrThrow(uid);
  const { partnerId } = resolvePartner(couple, uid);

  await db.runTransaction(async (tx) => {
    tx.update(coupleRef, {
      status: "disconnected",
      disconnectedAt: Timestamp.now(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.update(db.collection(Collections.users).doc(uid), {
      currentCoupleId: null,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  if (partnerId) {
    await sendPushToUser(partnerId, "partnerLeft", {
      titleKey: "push.partnerLeft.title",
      bodyKey: "push.partnerLeft.body",
    });
  }

  return { success: true };
});
