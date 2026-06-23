import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, createIssueSchema } from "../../utils/validation";
import { getCoupleContext } from "../../utils/couple-context";
import { sendPushToUser } from "../../utils/push";
import { CreateIssueInput, IssueDoc } from "../../types";

/**
 * createIssue (раздел 8.4, 18 ТЗ) — создание проблемы.
 *
 * Раздел 8.5 ТЗ: подсказка против агрессивных формулировок показывается
 * клиентом перед отправкой ("В MVP — только подсказка"), backend не
 * модерирует текст — это сознательное решение MVP, переоценка отложена
 * до AI-функций после MVP (раздел 28 ТЗ).
 */
export const createIssue = onCall<CreateIssueInput>(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(createIssueSchema, request.data);
  const { couple, partner } = await getCoupleContext(uid);

  const issueRef = db.collection(Collections.issues).doc();
  const now = Timestamp.now();

  const issueDoc: IssueDoc = {
    id: issueRef.id,
    coupleId: couple.id,
    authorId: uid,
    title: input.title,
    description: input.description ?? null,
    feelings: input.feelings ?? [],
    importanceLevel: input.importanceLevel,
    desiredOutcome: input.desiredOutcome ?? null,
    category: input.category,
    status: "open",
    createdAt: now,
    updatedAt: now,
    solvedAt: null,
    reopenedAt: null,
    archivedAt: null,
    messageCount: 0,
    lastMessageAt: null,
  };

  await issueRef.set(issueDoc);

  if (partner.partnerId) {
    await sendPushToUser(partner.partnerId, "newIssue", {
      titleKey: "push.newIssue.title",
      bodyKey: "push.newIssue.body",
      data: { issueId: issueRef.id },
    });
  }

  return { issueId: issueRef.id };
});
