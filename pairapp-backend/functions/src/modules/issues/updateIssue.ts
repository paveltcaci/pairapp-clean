import { onCall } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, updateIssueSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { IssueDoc, UpdateIssueInput } from "../../types";

/**
 * updateIssue (раздел 18 ТЗ) — обновление полей проблемы.
 *
 * ТЗ не уточняет, кто имеет право редактировать карточку (автор или
 * любой партнёр пары). Разумное и безопасное по умолчанию решение —
 * только автор может менять содержание (title/description/feelings/
 * importanceLevel/desiredOutcome/category); партнёр выражает позицию
 * через ветку обсуждения (раздел 8.6 ТЗ), а не правкой чужой карточки.
 * Это решение можно ослабить позже, если продукт явно потребует иного.
 */
export const updateIssue = onCall<UpdateIssueInput>(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(updateIssueSchema, request.data);
  const { couple } = await getActiveCoupleOrThrow(uid);
  resolvePartner(couple, uid); // бросит permissionDenied, если uid не в паре

  const issueRef = db.collection(Collections.issues).doc(input.issueId);
  const issueSnap = await issueRef.get();
  if (!issueSnap.exists) {
    throw Errors.notFound("Проблема");
  }
  const issue = issueSnap.data() as IssueDoc;

  if (issue.coupleId !== couple.id) {
    throw Errors.permissionDenied("Эта проблема принадлежит другой паре.");
  }
  if (issue.authorId !== uid) {
    throw Errors.permissionDenied("Редактировать карточку может только автор.");
  }
  if (issue.status === "archived") {
    throw Errors.failedPrecondition("Архивную проблему нельзя редактировать.");
  }

  const patch: Record<string, unknown> = { updatedAt: FieldValue.serverTimestamp() };
  if (input.title !== undefined) patch.title = input.title;
  if (input.description !== undefined) patch.description = input.description;
  if (input.feelings !== undefined) patch.feelings = input.feelings;
  if (input.importanceLevel !== undefined) patch.importanceLevel = input.importanceLevel;
  if (input.desiredOutcome !== undefined) patch.desiredOutcome = input.desiredOutcome;
  if (input.category !== undefined) patch.category = input.category;

  await issueRef.update(patch);
  return { success: true };
});
