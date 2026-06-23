import { onCall } from "firebase-functions/v2/https";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, reopenIssueSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { sendPushToUser } from "../../utils/push";
import { IssueDoc, IssueMessageDoc } from "../../types";

/**
 * reopenIssue (раздел 8.3, 8.7, 18 ТЗ) — "Открыта повторно", переход
 * из agreed/solved. В обычном потоке выполняется автоматически через
 * processCheckinResult при ответе "Нет" (раздел 9.4 ТЗ), но также
 * доступна пользователю напрямую — например, если проблема вернулась
 * без планового check-in.
 *
 * Создаёт системное сообщение типа `reopen` в ветке обсуждения (раздел
 * 8.6 ТЗ — таблица типов сообщений включает reopen как тип, значит он
 * должен появляться в треде, а не только менять статус "невидимо").
 */
export const reopenIssue = onCall<{ issueId: string; reason?: string }>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(reopenIssueSchema, request.data);
    const { couple } = await getActiveCoupleOrThrow(uid);
    const { partnerId } = resolvePartner(couple, uid);

    const issueRef = db.collection(Collections.issues).doc(input.issueId);

    await db.runTransaction(async (tx) => {
      const issueSnap = await tx.get(issueRef);
      if (!issueSnap.exists) {
        throw Errors.notFound("Проблема");
      }
      const issue = issueSnap.data() as IssueDoc;

      if (issue.coupleId !== couple.id) {
        throw Errors.permissionDenied("Эта проблема принадлежит другой паре.");
      }
      if (!["agreed", "solved"].includes(issue.status)) {
        throw Errors.failedPrecondition(
          `Переоткрыть можно только проблему со статусом 'agreed' или 'solved' (текущий: '${issue.status}').`
        );
      }

      const now = Timestamp.now();
      tx.update(issueRef, {
        status: "reopened",
        reopenedAt: now,
        updatedAt: FieldValue.serverTimestamp(),
        messageCount: FieldValue.increment(1),
        lastMessageAt: now,
      });

      if (input.reason) {
        const messageRef = db.collection(Collections.issueMessages).doc();
        const messageDoc: IssueMessageDoc = {
          id: messageRef.id,
          issueId: input.issueId,
          coupleId: couple.id,
          authorId: uid,
          type: "reopen",
          text: input.reason,
          createdAt: now,
          updatedAt: null,
          isDeleted: false,
          readByPartner: false,
        };
        tx.set(messageRef, messageDoc);
      }
    });

    if (partnerId) {
      await sendPushToUser(partnerId, "issueReply", {
        titleKey: "push.issueReopened.title",
        bodyKey: "push.issueReopened.body",
        data: { issueId: input.issueId },
      });
    }

    return { success: true };
  }
);
