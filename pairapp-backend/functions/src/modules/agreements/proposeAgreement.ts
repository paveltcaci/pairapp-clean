import { onCall } from "firebase-functions/v2/https";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, proposeAgreementSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { sendPushToUser } from "../../utils/push";
import { AgreementDoc, IssueDoc, ProposeAgreementInput } from "../../types";

/**
 * proposeAgreement (раздел 9.1, 9.2, 18 ТЗ) — "Договорённость может быть
 * создана из карточки проблемы или вручную" (issueId опционален).
 *
 * Раздел 8.3 ТЗ: если есть issueId, статус проблемы должен перейти в
 * agreement_proposed (переход допустим из in_discussion — таблица раздела
 * 8.3). Если проблема ещё в open/reopened, тоже разрешаем — на практике
 * партнёры иногда сразу предлагают решение без долгого обсуждения
 * (раздел 8.7 пример цикла это не запрещает явно).
 *
 * Решение по статусу 'proposed' (раздел 9.3 ТЗ — "Предложена одним
 * партнёром"): мы создаём договорённость сразу в статусе accepted_by_one,
 * считая автора предложения согласным с собственным предложением. Раздел
 * 9.3 формально предполагает промежуточный статус 'proposed' до того, как
 * хотя бы кто-то её принял, но семантически нет смысла заставлять автора
 * вызывать acceptAgreement на своё же предложение. Поэтому статус
 * 'proposed' зарезервирован в типах, но в этом потоке не используется —
 * если продукт впоследствии решит явно различать "предложено" и "принято
 * автором", это локализованное изменение в одном месте.
 */
export const proposeAgreement = onCall<ProposeAgreementInput>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(proposeAgreementSchema, request.data);
    const { couple } = await getActiveCoupleOrThrow(uid);
    const { selfSlot, partnerId } = resolvePartner(couple, uid);

    const agreementRef = db.collection(Collections.agreements).doc();
    const now = Timestamp.now();

    const checkDate = input.customCheckDate
      ? Timestamp.fromDate(new Date(input.customCheckDate))
      : Timestamp.fromMillis(
          now.toMillis() + (input.checkIntervalDays ?? 0) * 24 * 60 * 60 * 1000
        );

    await db.runTransaction(async (tx) => {
      let issueRef: FirebaseFirestore.DocumentReference | null = null;

      if (input.issueId) {
        issueRef = db.collection(Collections.issues).doc(input.issueId);
        const issueSnap = await tx.get(issueRef);
        if (!issueSnap.exists) {
          throw Errors.notFound("Проблема");
        }
        const issue = issueSnap.data() as IssueDoc;
        if (issue.coupleId !== couple.id) {
          throw Errors.permissionDenied("Эта проблема принадлежит другой паре.");
        }
        if (!["open", "in_discussion", "reopened"].includes(issue.status)) {
          throw Errors.failedPrecondition(
            `Невозможно предложить договорённость для проблемы со статусом '${issue.status}'.`
          );
        }
      }

      const agreementDoc: AgreementDoc = {
        id: agreementRef.id,
        coupleId: couple.id,
        issueId: input.issueId ?? null,
        title: input.title,
        description: input.description ?? null,
        proposedBy: uid,
        // Автор предложения автоматически считается согласным со своим
        // предложением — иначе acceptAgreement пришлось бы вызывать и ему.
        acceptedByPartnerA: selfSlot === "A",
        acceptedByPartnerB: selfSlot === "B",
        status: "accepted_by_one",
        checkIntervalDays: input.checkIntervalDays ?? null,
        checkDate,
        createdAt: now,
        updatedAt: now,
      };
      tx.set(agreementRef, agreementDoc);

      if (issueRef) {
        tx.update(issueRef, {
          status: "agreement_proposed",
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
    });

    if (partnerId) {
      await sendPushToUser(partnerId, "solutionProposed", {
        titleKey: "push.agreementProposed.title",
        bodyKey: "push.agreementProposed.body",
        data: { agreementId: agreementRef.id },
      });
    }

    return { agreementId: agreementRef.id };
  }
);
