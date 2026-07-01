import { onCall } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, softDeleteChoreTaskSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow } from "../../utils/couple-context";
import { ChoreTaskDoc, SoftDeleteChoreTaskInput } from "../../types";
import { Errors } from "../../utils/errors";

/** softDeleteChoreTask — мягкое удаление бытовой задачи (isActive = false). */
export const softDeleteChoreTask = onCall<SoftDeleteChoreTaskInput>(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(softDeleteChoreTaskSchema, request.data);
  const { couple } = await getActiveCoupleOrThrow(uid);

  const taskRef = db.collection(Collections.choreTasks).doc(input.choreTaskId);
  const taskSnap = await taskRef.get();

  if (!taskSnap.exists) {
    throw Errors.notFound("Бытовая задача");
  }

  const task = taskSnap.data() as ChoreTaskDoc;

  if (task.coupleId !== couple.id) {
    throw Errors.permissionDenied("Эта задача принадлежит другой паре.");
  }

  await taskRef.update({
    isActive: false,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { success: true };
});
