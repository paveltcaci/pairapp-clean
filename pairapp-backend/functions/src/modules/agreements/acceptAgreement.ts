import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { z } from 'zod';

const db = getFirestore();

const AcceptAgreementSchema = z.object({
  agreementId: z.string(),
});

export const acceptAgreement = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Пользователь не авторизован');

  const { agreementId } = AcceptAgreementSchema.parse(request.data);

  const agreementRef = db.collection('agreements').doc(agreementId);
  const agreementSnap = await agreementRef.get();

  if (!agreementSnap.exists) {
    throw new HttpsError('not-found', 'Договорённость не найдена');
  }

  const agreement = agreementSnap.data()!;
  const coupleSnap = await db.collection('couples').doc(agreement.coupleId).get();
  const couple = coupleSnap.data()!;

  const isPartnerA = couple.partnerAId === uid;
  const isPartnerB = couple.partnerBId === uid;

  if (!isPartnerA && !isPartnerB) {
    throw new HttpsError('permission-denied', 'Вы не состоите в паре');
  }

  // Определяем, кого принимаем
  const updateData: any = { updatedAt: Timestamp.now() };

  if (isPartnerA && !agreement.acceptedByPartnerA) {
    updateData.acceptedByPartnerA = true;
  } else if (isPartnerB && !agreement.acceptedByPartnerB) {
    updateData.acceptedByPartnerB = true;
  } else {
    throw new HttpsError('failed-precondition', 'Вы уже приняли эту договорённость');
  }

  const newAcceptedA = updateData.acceptedByPartnerA ?? agreement.acceptedByPartnerA;
  const newAcceptedB = updateData.acceptedByPartnerB ?? agreement.acceptedByPartnerB;

  if (newAcceptedA && newAcceptedB) {
    updateData.status = 'active';
  } else {
    updateData.status = 'accepted_by_one';
  }

  await agreementRef.update(updateData);

  // Если оба приняли — создаём check-in (если ещё не создан)
  if (newAcceptedA && newAcceptedB && agreement.status !== 'active') {
    const checkDate = agreement.checkDate || Timestamp.now();
    await createInitialCheckin(agreementId, agreement.coupleId, agreement.issueId, checkDate);
  }

  return { success: true, status: updateData.status };
});

async function createInitialCheckin(agreementId: string, coupleId: string, issueId: string | null, checkDate: any) {
  const existing = await db.collection('checkins')
    .where('agreementId', '==', agreementId)
    .where('status', '==', 'pending')
    .get();

  if (existing.empty) {
    await db.collection('checkins').add({
      agreementId,
      coupleId,
      issueId,
      scheduledAt: checkDate,
      partnerAAnswer: null,
      partnerBAnswer: null,
      partnerAAnsweredAt: null,
      partnerBAnsweredAt: null,
      status: 'pending',
      result: null,
      createdAt: Timestamp.now(),
      completedAt: null,
    });
  }
}