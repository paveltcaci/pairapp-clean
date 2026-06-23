import { onCall } from "firebase-functions/v2/https";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, acceptAgreementSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { sendPushToUser } from "../../utils/push";
import {
  AcceptAgreementInput,
  AgreementDoc,
  CheckinDoc,
  IssueDoc,
  IssueMessageDoc,
} from "../../types";

/**
 * acceptAgreement.
 *
 * Важно:
 * В Firestore transaction все чтения должны быть ДО любых записей.
 * Поэтому issue читаем заранее, а уже потом создаём checkin/message и обновляем документы.
 */
export const acceptAgreement = onCall<AcceptAgreementInput>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(acceptAgreementSchema, request.data);
    const { couple } = await getActiveCoupleOrThrow(uid);
    const { selfSlot, partnerId } = resolvePartner(couple, uid);

    const agreementRef = db.collection(Collections.agreements).doc(input.agreementId);

    const result = await db.runTransaction(async (tx) => {
      const agreementSnap = await tx.get(agreementRef);

      if (!agreementSnap.exists) {
        throw Errors.notFound("Договорённость");
      }

      const agreement = agreementSnap.data() as AgreementDoc;

      if (agreement.coupleId !== couple.id) {
        throw Errors.permissionDenied("Эта договорённость принадлежит другой паре.");
      }

      if (!["proposed", "accepted_by_one"].includes(agreement.status)) {
        throw Errors.failedPrecondition(
          `Договорённость со статусом '${agreement.status}' уже не ожидает принятия.`
        );
      }

      const alreadyAcceptedBySelf =
        selfSlot === "A" ? agreement.acceptedByPartnerA : agreement.acceptedByPartnerB;

      if (alreadyAcceptedBySelf) {
        return {
          agreementId: agreementRef.id,
          becameActive: false,
          alreadyAccepted: true,
          checkinId: null,
        };
      }

      const now = Timestamp.now();

      const acceptedByPartnerA = selfSlot === "A" ? true : agreement.acceptedByPartnerA;
      const acceptedByPartnerB = selfSlot === "B" ? true : agreement.acceptedByPartnerB;
      const bothAccepted = acceptedByPartnerA && acceptedByPartnerB;

      const issueRef = agreement.issueId
        ? db.collection(Collections.issues).doc(agreement.issueId)
        : null;

      let shouldUpdateIssueToAgreed = false;

      if (bothAccepted && issueRef) {
        const issueSnap = await tx.get(issueRef);

        if (issueSnap.exists) {
          const issue = issueSnap.data() as IssueDoc;
          shouldUpdateIssueToAgreed = issue.status === "agreement_proposed";
        }
      }

      const agreementPatch: Record<string, unknown> = {
        acceptedByPartnerA,
        acceptedByPartnerB,
        updatedAt: FieldValue.serverTimestamp(),
      };

      let checkinId: string | null = null;

      if (bothAccepted) {
        agreementPatch.status = "active";

        const checkinRef = db.collection(Collections.checkins).doc();
        checkinId = checkinRef.id;

        const checkinDoc: CheckinDoc = {
          id: checkinRef.id,
          agreementId: agreementRef.id,
          issueId: agreement.issueId,
          coupleId: couple.id,
          scheduledAt: agreement.checkDate ?? now,
          partnerAAnswer: null,
          partnerBAnswer: null,
          partnerAAnsweredAt: null,
          partnerBAnsweredAt: null,
          status: "pending",
          result: null,
          createdAt: now,
          completedAt: null,
          notifiedAt: null,
        };

        tx.set(checkinRef, checkinDoc);

        if (issueRef && shouldUpdateIssueToAgreed) {
          tx.update(issueRef, {
            status: "agreed",
            updatedAt: FieldValue.serverTimestamp(),
          });
        }

        if (agreement.issueId) {
          const messageRef = db.collection(Collections.issueMessages).doc();

          const messageDoc: IssueMessageDoc = {
            id: messageRef.id,
            issueId: agreement.issueId,
            coupleId: couple.id,
            authorId: uid,
            type: "agreement",
            text: agreement.title,
            createdAt: now,
            updatedAt: null,
            isDeleted: false,
            readByPartner: false,
          };

          tx.set(messageRef, messageDoc);
        }
      } else {
        agreementPatch.status = "accepted_by_one";
      }

      tx.update(agreementRef, agreementPatch);

      return {
        agreementId: agreementRef.id,
        becameActive: bothAccepted,
        alreadyAccepted: false,
        checkinId,
      };
    });

    if (partnerId && !result.alreadyAccepted) {
      await sendPushToUser(partnerId, "agreementAccepted", {
        titleKey: result.becameActive
          ? "push.agreementActive.title"
          : "push.agreementAccepted.title",
        bodyKey: result.becameActive
          ? "push.agreementActive.body"
          : "push.agreementAccepted.body",
        data: { agreementId: input.agreementId },
      });
    }

    return result;
  }
);