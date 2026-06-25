import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { parseOrThrow, proposeAgreementSchema } from '../../utils/validation';

const db = getFirestore();

export const proposeAgreement = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Не авторизован');

  const data = parseOrThrow(proposeAgreementSchema, request.data);
  if (data.title.length < 3) {
    throw new HttpsError('invalid-argument', 'Название должно быть не короче 3 символов.');
  }

  const issueId = data.issueId?.trim() || null;
  const description = data.description?.trim() || null;

  // Получаем пару пользователя
  const userDoc = await db.collection('users').doc(uid).get();
  const coupleId = userDoc.data()?.currentCoupleId;
  if (!coupleId) throw new HttpsError('failed-precondition', 'У пользователя нет активной пары');

  const coupleSnap = await db.collection('couples').doc(coupleId).get();
  const couple = coupleSnap.data();
  if (!couple) throw new HttpsError('not-found', 'Пара не найдена');

  const isPartnerA = couple.partnerAId === uid;
  const isPartnerB = couple.partnerBId === uid;
  if (!isPartnerA && !isPartnerB) {
    throw new HttpsError('permission-denied', 'Вы не состоите в этой паре');
  }

  // Если есть issueId — проверяем, что проблема существует
  let issueRef: FirebaseFirestore.DocumentReference | null = null;
  if (issueId) {
    issueRef = db.collection('issues').doc(issueId);
    const issueSnap = await issueRef.get();
    if (!issueSnap.exists || issueSnap.data()!.coupleId !== coupleId) {
      throw new HttpsError('not-found', 'Проблема не найдена');
    }
  }

  const now = Timestamp.now();

  // Вычисляем дату проверки
  let checkDate: Timestamp;
  if (data.customCheckDate) {
    checkDate = Timestamp.fromDate(new Date(data.customCheckDate));
  } else {
    const days = data.checkIntervalDays ?? 7;
    checkDate = Timestamp.fromMillis(now.toMillis() + days * 24 * 60 * 60 * 1000);
  }

  const agreementData = {
    coupleId,
    issueId,
    title: data.title,
    description,
    proposedBy: uid,
    acceptedByPartnerA: isPartnerA,
    acceptedByPartnerB: isPartnerB,
    status: (isPartnerA && isPartnerB) ? 'accepted_by_both' : 'accepted_by_one',
    checkIntervalDays: data.checkIntervalDays ?? null,
    checkDate,
    createdAt: now,
    updatedAt: now,
  };

  const agreementRef = await db.collection('agreements').add(agreementData);

  // Обновляем статус проблемы (если передан issueId)
  if (issueRef) {
    await issueRef.update({
      status: 'agreement_proposed',
      updatedAt: now,
    });
  }

  // Если оба сразу приняли — создаём первый check-in
  if (agreementData.status === 'accepted_by_both') {
    await db.collection('checkins').add({
      agreementId: agreementRef.id,
      coupleId,
      issueId,
      scheduledAt: checkDate,
      partnerAAnswer: null,
      partnerBAnswer: null,
      partnerAAnsweredAt: null,
      partnerBAnsweredAt: null,
      status: 'pending',
      result: null,
      createdAt: now,
    });
  }

  return { agreementId: agreementRef.id };
});
