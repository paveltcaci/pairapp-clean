import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, createReportSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { CreateReportInput, ReportDoc } from "../../types";

/**
 * createReport (раздел 16.1, 18 ТЗ): "Пользователь может пожаловаться на
 * проблему, сообщение или профиль партнёра."
 *
 * В паре всего два человека, поэтому reportedUserId всегда — текущий
 * партнёр (raздел 16.1 ТЗ говорит именно "профиль партнёра" — жалоба не
 * на третьих лиц, т.к. их в этой модели данных нет).
 */
export const createReport = onCall<CreateReportInput>(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(createReportSchema, request.data);
  const { couple } = await getActiveCoupleOrThrow(uid);
  const { partnerId } = resolvePartner(couple, uid);

  if (!partnerId) {
    throw Errors.failedPrecondition(
      "Невозможно отправить жалобу: в паре нет второго партнёра."
    );
  }

  const reportRef = db.collection(Collections.reports).doc();
  const reportDoc: ReportDoc = {
    id: reportRef.id,
    reporterId: uid,
    reportedUserId: partnerId,
    coupleId: couple.id,
    targetType: input.targetType,
    targetId: input.targetId,
    reason: input.reason,
    comment: input.comment ?? null,
    status: "pending",
    createdAt: Timestamp.now(),
    reviewedAt: null,
    reviewedBy: null,
    adminNote: null,
  };

  await reportRef.set(reportDoc);
  return { reportId: reportRef.id };
});
