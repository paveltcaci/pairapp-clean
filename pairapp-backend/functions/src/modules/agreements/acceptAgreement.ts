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
  const result = await db.runTransaction(async (tx) => {
    const agreementSnap = await tx.get(agreementRef);

    if (!agreementSnap.exists) {
      throw new HttpsError('not-found', 'Договорённость не найдена');
    }

    const agreement = agreementSnap.data()!;
    const coupleRef = db.collection('couples').doc(agreement.coupleId);
    const coupleSnap = await tx.get(coupleRef);

    if (!coupleSnap.exists) {
      throw new HttpsError('not-found', 'Пара не найдена');
    }

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

    const becameActive = newAcceptedA && newAcceptedB && agreement.status !== 'active';

    if (newAcceptedA && newAcceptedB) {
      updateData.status = 'active';
    } else {
      updateData.status = 'accepted_by_one';
    }

    let checkinId: string | null = null;

    // Если оба приняли — создаём check-in (если ещё не создан)
    if (becameActive) {
      const checkDate = agreement.checkDate || Timestamp.now();
      checkinId = await createInitialCheckin(
        tx,
        agreementId,
        agreement.coupleId,
        agreement.issueId,
        checkDate,
      );
    }

    tx.update(agreementRef, updateData);

    if (becameActive) {
      if (agreement.issueId) {
        tx.update(db.collection('issues').doc(agreement.issueId), {
          status: 'agreed',
          updatedAt: Timestamp.now(),
        });
      }
    }

    return {
      status: updateData.status,
      becameActive,
      checkinId,
    };
  });

  return {
    success: true,
    status: result.status,
    becameActive: result.becameActive,
    ...(result.checkinId ? { checkinId: result.checkinId } : {}),
  };
});

async function createInitialCheckin(tx: FirebaseFirestore.Transaction, agreementId: string, coupleId: string, issueId: string | null, checkDate: any) {
  const existing = await tx.get(db.collection('checkins')
    .where('agreementId', '==', agreementId)
    .where('status', '==', 'pending'));

  if (existing.empty) {
    const checkinRef = db.collection('checkins').doc();
    tx.set(checkinRef, {
      id: checkinRef.id,
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

    return checkinRef.id;
  }

  return existing.docs[0].id;
}
