import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, createActivitySchema } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { sendPushToUser } from "../../utils/push";
import { ActivityDoc, CreateActivityInput } from "../../types";

/**
 * createActivity (раздел 11.3, 18 ТЗ): "Оба партнёра могут добавлять свои
 * идеи... Пользовательские идеи участвуют в рандомайзере наравне со
 * встроенными."
 */
export const createActivity = onCall<CreateActivityInput>(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(createActivitySchema, request.data);
  const { couple } = await getActiveCoupleOrThrow(uid);
  const { partnerId } = resolvePartner(couple, uid);

  const activityRef = db.collection(Collections.activities).doc();
  const activityDoc: ActivityDoc = {
    id: activityRef.id,
    coupleId: couple.id,
    title: input.title,
    description: input.description,
    category: input.category,
    durationMinutes: input.durationMinutes ?? null,
    budgetLevel: input.budgetLevel,
    source: "user_created",
    createdBy: uid,
    isActive: true,
    createdAt: Timestamp.now(),
  };

  await activityRef.set(activityDoc);

  if (partnerId) {
    await sendPushToUser(partnerId, "activityIdeaAdded", {
      titleKey: "push.activityIdeaAdded.title",
      bodyKey: "push.activityIdeaAdded.body",
      data: { activityId: activityRef.id },
    });
  }

  return { activityId: activityRef.id };
});
