import { onCall } from "firebase-functions/v2/https";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, solveIssueSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { IssueDoc } from "../../types";

/**
 * solveIssue (раздел 8.3, 18 ТЗ) — "Решена (оба подтвердили)".
 *
 * В обычном потоке проблема переходит в solved автоматически через
 * processCheckinResult (раздел 9.4 ТЗ: "Оба «Да» → Проблема → solved").
 * Эта callable-функция — explicit-путь для случая, когда у проблемы нет
 * связанной договорённости с check-in (например, партнёры устно решили
 * вопрос и просто закрывают карточку) — раздел 9.1 ТЗ допускает создание
 * договорённости "вручную", но не обязывает её для каждой проблемы.
 */
export const solveIssue = onCall<{ issueId: string }>(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(solveIssueSchema, request.data);
  const { couple } = await getActiveCoupleOrThrow(uid);
  resolvePartner(couple, uid);

  const issueRef = db.collection(Collections.issues).doc(input.issueId);
  const issueSnap = await issueRef.get();
  if (!issueSnap.exists) {
    throw Errors.notFound("Проблема");
  }
  const issue = issueSnap.data() as IssueDoc;

  if (issue.coupleId !== couple.id) {
    throw Errors.permissionDenied("Эта проблема принадлежит другой паре.");
  }
  if (!["agreed", "agreement_proposed", "in_discussion"].includes(issue.status)) {
    throw Errors.failedPrecondition(
      `Невозможно закрыть проблему со статусом '${issue.status}'.`
    );
  }

  await issueRef.update({
    status: "solved",
    solvedAt: Timestamp.now(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { success: true };
});
