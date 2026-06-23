import { onCall } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { requireAuth } from "../../utils/auth";
import { Errors } from "../../utils/errors";
import { generateUniqueInviteCode } from "../../utils/invite-code";
import { getActiveCoupleOrThrow } from "../../utils/couple-context";

/**
 * regenerateInviteCode (раздел 6.2, 18 ТЗ): "Код можно пересоздать
 * вручную (кнопка «Обновить код»), если партнёр ещё не подключился."
 */
export const regenerateInviteCode = onCall(async (request) => {
  const uid = requireAuth(request);
  const { couple, coupleRef } = await getActiveCoupleOrThrow(uid);

  if (couple.partnerBId) {
    throw Errors.failedPrecondition(
      "Партнёр уже подключён к паре — пересоздание кода не требуется."
    );
  }

  const newCode = await generateUniqueInviteCode();
  await coupleRef.update({
    inviteCode: newCode,
    inviteCodeUsed: false,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { inviteCode: newCode };
});
