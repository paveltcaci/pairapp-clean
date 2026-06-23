import { db, Collections } from "../config/firebase";
import { CoupleDoc, PartnerResolution, UserDoc } from "../types";
import { Errors } from "./errors";

/**
 * Загружает документ пользователя. Бросает notFound, если профиля нет
 * (теоретически невозможно после createUserProfile, но защищаемся).
 */
export async function getUserOrThrow(userId: string): Promise<UserDoc> {
  const snap = await db.collection(Collections.users).doc(userId).get();
  if (!snap.exists) {
    throw Errors.notFound("Профиль пользователя");
  }
  return snap.data() as UserDoc;
}

/**
 * Загружает активную пару пользователя. Бросает failedPrecondition,
 * если у пользователя нет текущей пары — большинство модулей (Issues,
 * Agreements, Activities, Quizzes, Chores) требуют активную пару.
 */
export async function getActiveCoupleOrThrow(
  userId: string
): Promise<{ couple: CoupleDoc; coupleRef: FirebaseFirestore.DocumentReference }> {
  const user = await getUserOrThrow(userId);
  if (!user.currentCoupleId) {
    throw Errors.failedPrecondition(
      "У вас нет активной пары. Создайте пару или подключитесь по коду."
    );
  }
  const coupleRef = db.collection(Collections.couples).doc(user.currentCoupleId);
  const coupleSnap = await coupleRef.get();
  if (!coupleSnap.exists) {
    throw Errors.notFound("Пара");
  }
  const couple = coupleSnap.data() as CoupleDoc;
  if (couple.status !== "active") {
    throw Errors.failedPrecondition(
      `Пара недоступна (статус: ${couple.status}).`
    );
  }
  return { couple, coupleRef };
}

/**
 * Определяет, является ли userId партнёром A или B в данной паре,
 * и кто его партнёр. Бросает permissionDenied, если userId не входит
 * в пару — это главный guard против доступа к чужим данным на уровне
 * Cloud Functions (зеркалится правилами Firestore, раздел 21 ТЗ).
 */
export function resolvePartner(
  couple: CoupleDoc,
  userId: string
): PartnerResolution {
  if (couple.partnerAId === userId) {
    return {
      selfSlot: "A",
      partnerSlot: "B",
      selfId: userId,
      partnerId: couple.partnerBId,
    };
  }
  if (couple.partnerBId === userId) {
    return {
      selfSlot: "B",
      partnerSlot: "A",
      selfId: userId,
      partnerId: couple.partnerAId,
    };
  }
  throw Errors.permissionDenied("Вы не состоите в этой паре.");
}

/** Удобный шорткат: получить и пару, и резолв партнёра одним вызовом. */
export async function getCoupleContext(userId: string) {
  const { couple, coupleRef } = await getActiveCoupleOrThrow(userId);
  const partner = resolvePartner(couple, userId);
  return { couple, coupleRef, partner };
}
