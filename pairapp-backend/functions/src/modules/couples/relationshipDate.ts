import { onCall } from "firebase-functions/v2/https";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, updateRelationshipStartDateSchema } from "../../utils/validation";
import { getCoupleContext } from "../../utils/couple-context";
import { sendPushToUser } from "../../utils/push";
import { Errors } from "../../utils/errors";

/**
 * updateRelationshipStartDate (раздел 10.1, 18 ТЗ): "Один из партнёров
 * вводит дату начала отношений. Второй подтверждает или предлагает
 * другую дату. При расхождении оба видят уведомление о необходимости
 * согласовать дату."
 *
 * Также используется для изменения уже установленной даты — раздел
 * 15.2 ТЗ: "Изменить дату начала отношений (требует подтверждения
 * партнёра)". В обоих случаях логика идентична: установка даты сбрасывает
 * подтверждение второго партнёра и требует повторного согласования.
 */
export const updateRelationshipStartDate = onCall<{ date: string }>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(updateRelationshipStartDateSchema, request.data);
    const { coupleRef, partner } = await getCoupleContext(uid);

    const date = Timestamp.fromDate(new Date(input.date));

    await coupleRef.update({
      relationshipStartDate: date,
      relationshipStartConfirmedByA: partner.selfSlot === "A",
      relationshipStartConfirmedByB: partner.selfSlot === "B",
      updatedAt: FieldValue.serverTimestamp(),
    });

    if (partner.partnerId) {
      await sendPushToUser(partner.partnerId, "anniversary", {
        titleKey: "push.relationshipDateProposed.title",
        bodyKey: "push.relationshipDateProposed.body",
        params: { date: input.date },
      });
    }

    return { success: true };
  }
);

/**
 * confirmRelationshipStartDate (раздел 10.1, 18 ТЗ): подтверждение даты
 * вторым партнёром. Если партнёр не согласен — он должен вызвать
 * updateRelationshipStartDate с другой датой, а не "отклонить".
 */
export const confirmRelationshipStartDate = onCall(async (request) => {
  const uid = requireAuth(request);
  const { couple, coupleRef, partner } = await getCoupleContext(uid);

  if (!couple.relationshipStartDate) {
    throw Errors.failedPrecondition(
      "Дата начала отношений ещё не предложена."
    );
  }

  const alreadyConfirmedBySelf =
    partner.selfSlot === "A"
      ? couple.relationshipStartConfirmedByA
      : couple.relationshipStartConfirmedByB;
  if (alreadyConfirmedBySelf) {
    return { success: true, alreadyConfirmed: true };
  }

  const fieldToUpdate =
    partner.selfSlot === "A"
      ? "relationshipStartConfirmedByA"
      : "relationshipStartConfirmedByB";

  await coupleRef.update({
    [fieldToUpdate]: true,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { success: true, alreadyConfirmed: false };
});
