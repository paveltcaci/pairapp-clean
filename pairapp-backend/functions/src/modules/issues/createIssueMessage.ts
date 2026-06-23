import { onCall } from "firebase-functions/v2/https";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, createIssueMessageSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { sendPushToUser } from "../../utils/push";
import {
  CreateIssueMessageInput,
  IssueDoc,
  IssueMessageDoc,
  IssueMessageType,
  IssueStatus,
} from "../../types";

/**
 * Раздел 8.3 ТЗ задаёт статусы и допустимые переходы, а раздел 8.6/8.7
 * описывает, какой *тип сообщения* соответствует какому переходу.
 * Явной таблицы "тип сообщения → новый статус" в ТЗ нет, поэтому
 * сопоставление ниже — это интерпретация, выведенная из примера полного
 * цикла (раздел 8.7):
 *
 *   comment/objection  → open/reopened переходит в in_discussion
 *   solution           → in_discussion переходит в agreement_proposed
 *   agreement          → создаётся вместе с proposeAgreement, отдельно
 *                        не используется здесь (см. модуль agreements)
 *   checkin            → системное сообщение, создаётся processCheckinResult,
 *                        не ожидается от пользователя через эту функцию
 *   reopen             → пользователь не вызывает напрямую — переоткрытие
 *                        идёт через reopenIssue, которая сама создаёт
 *                        системное сообщение типа reopen
 *
 * Поэтому createIssueMessage принимает от пользователя только comment,
 * objection и solution — остальные типы зарезервированы для системных
 * вызовов (proposeAgreement, processCheckinResult, reopenIssue) и
 * отклоняются здесь явной проверкой.
 */
const USER_INITIATED_TYPES: IssueMessageType[] = ["comment", "objection", "solution"];

function nextStatusForMessage(
  current: IssueStatus,
  type: IssueMessageType
): IssueStatus | null {
  if (type === "solution") {
    if (current === "open" || current === "in_discussion" || current === "reopened") {
      return "agreement_proposed";
    }
    return null;
  }
  // comment / objection — обсуждение продолжается.
  if (current === "open" || current === "reopened") {
    return "in_discussion";
  }
  return null;
}

export const createIssueMessage = onCall<CreateIssueMessageInput>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(createIssueMessageSchema, request.data);

    if (!USER_INITIATED_TYPES.includes(input.type)) {
      throw Errors.invalidArgument(
        `Тип сообщения '${input.type}' создаётся системой автоматически и недоступен для прямой отправки.`
      );
    }

    const { couple } = await getActiveCoupleOrThrow(uid);
    const { partnerId } = resolvePartner(couple, uid);

    const issueRef = db.collection(Collections.issues).doc(input.issueId);

    const result = await db.runTransaction(async (tx) => {
      const issueSnap = await tx.get(issueRef);
      if (!issueSnap.exists) {
        throw Errors.notFound("Проблема");
      }
      const issue = issueSnap.data() as IssueDoc;

      if (issue.coupleId !== couple.id) {
        throw Errors.permissionDenied("Эта проблема принадлежит другой паре.");
      }
      if (issue.status === "archived") {
        throw Errors.failedPrecondition(
          "Архивная проблема закрыта для новых сообщений."
        );
      }

      const messageRef = db.collection(Collections.issueMessages).doc();
      const now = Timestamp.now();

      const messageDoc: IssueMessageDoc = {
        id: messageRef.id,
        issueId: input.issueId,
        coupleId: couple.id,
        authorId: uid,
        type: input.type,
        text: input.text,
        createdAt: now,
        updatedAt: null,
        isDeleted: false,
        readByPartner: false,
      };
      tx.set(messageRef, messageDoc);

      const newStatus = nextStatusForMessage(issue.status, input.type);
      const issuePatch: Record<string, unknown> = {
        messageCount: FieldValue.increment(1),
        lastMessageAt: now,
        updatedAt: FieldValue.serverTimestamp(),
      };
      if (newStatus) {
        issuePatch.status = newStatus;
      }
      tx.update(issueRef, issuePatch);

      return { messageId: messageRef.id, newStatus };
    });

    // Раздел 14 ТЗ различает получателя по типу события:
    // "Партнёр ответил на проблему" → автор проблемы (а не "партнёр"
    // вообще — если автор отвечает сам себе после правок, получателя нет).
    // "Партнёр предложил решение" → второй партнёр.
    const issueSnapForPush = await issueRef.get();
    const issueForPush = issueSnapForPush.data() as IssueDoc;

    if (input.type === "solution") {
      if (partnerId) {
        await sendPushToUser(partnerId, "solutionProposed", {
          titleKey: "push.solutionProposed.title",
          bodyKey: "push.solutionProposed.body",
          data: { issueId: input.issueId },
        });
      }
    } else {
      const recipientId =
        issueForPush.authorId !== uid ? issueForPush.authorId : partnerId;
      if (recipientId) {
        await sendPushToUser(recipientId, "issueReply", {
          titleKey: "push.issueReply.title",
          bodyKey: "push.issueReply.body",
          data: { issueId: input.issueId },
        });
      }
    }

    return result;
  }
);
