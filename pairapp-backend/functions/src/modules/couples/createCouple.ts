import { onCall } from "firebase-functions/v2/https";
import { Timestamp, FieldValue } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { Errors } from "../../utils/errors";
import { generateUniqueInviteCode } from "../../utils/invite-code";
import { CoupleDoc, DEFAULT_COUPLE_SETTINGS, UserDoc } from "../../types";

/**
 * createCouple (раздел 6.1, 18 ТЗ): "Пользователь нажимает «Создать
 * пару» — создаётся объект Couple, генерируется invite-код."
 *
 * Раздел 6.3 ТЗ: "Один пользователь — одна активная пара" — проверяем,
 * что у пользователя ещё нет currentCoupleId.
 */
export const createCouple = onCall(async (request) => {
  const uid = requireAuth(request);

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
        "У вас уже есть активная пара. Выйдите из текущей пары, чтобы создать новую."
      );
    }
    // Пара существует, но disconnected/blocked/deleted (партнёр вышел или
    // удалил аккаунт первым) — currentCoupleId на пользователе устарел,
    // чистим его перед созданием новой пары (раздел 6.3 ТЗ: "После выхода
    // пользователь может создать новую пару").
  }

  const inviteCode = await generateUniqueInviteCode();
  const coupleRef = db.collection(Collections.couples).doc();
  const now = Timestamp.now();

  const coupleDoc: CoupleDoc = {
    id: coupleRef.id,
    partnerAId: uid,
    partnerBId: null,
    relationshipStartDate: null,
    relationshipStartConfirmedByA: false,
    relationshipStartConfirmedByB: false,
    inviteCode,
    inviteCodeUsed: false,
    status: "active",
    createdAt: now,
    updatedAt: now,
    disconnectedAt: null,
    settings: DEFAULT_COUPLE_SETTINGS,
  };

  await db.runTransaction(async (tx) => {
    tx.set(coupleRef, coupleDoc);
    tx.update(userRef, {
      currentCoupleId: coupleRef.id,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  return { coupleId: coupleRef.id, inviteCode };
});
