import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, createChoreTaskSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow } from "../../utils/couple-context";
import { ChoreTaskDoc, CreateChoreTaskInput } from "../../types";

/** createChoreTask (раздел 12.3, 18 ТЗ) — создание бытовой задачи. */
export const createChoreTask = onCall<CreateChoreTaskInput>(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(createChoreTaskSchema, request.data);
  const { couple } = await getActiveCoupleOrThrow(uid);

  const taskRef = db.collection(Collections.choreTasks).doc();
  const now = Timestamp.now();
  const taskDoc: ChoreTaskDoc = {
    id: taskRef.id,
    coupleId: couple.id,
    title: input.title,
    description: input.description ?? null,
    emoji: input.emoji ?? "🧹",
    category: input.category ?? "другое",
    intensity: input.intensity ?? "medium",
    estimatedMinutes: input.estimatedMinutes ?? null,
    createdBy: uid,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  };

  await taskRef.set(taskDoc);
  return { choreTaskId: taskRef.id };
});
