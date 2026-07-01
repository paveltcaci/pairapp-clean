import { onCall } from "firebase-functions/v2/https";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, removeSavedActivityIdeaSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { ActivityHistoryDoc } from "../../types";

/**
 * removeSavedActivityIdea — удаляет сохранённую идею из activity_history.
 *
 * Проверяет:
 * 1. Пользователь аутентифицирован
 * 2. Документ существует
 * 3. coupleId документа совпадает с активной парой пользователя
 *    (запрещает удаление чужих записей)
 */
export const removeSavedActivityIdea = onCall<unknown>(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(removeSavedActivityIdeaSchema, request.data);
  const { couple } = await getActiveCoupleOrThrow(uid);

  const historyRef = db
    .collection(Collections.activityHistory)
    .doc(input.historyId);

  const snap = await historyRef.get();
  if (!snap.exists) {
    throw Errors.notFound("Сохранённая идея");
  }

  const doc = snap.data() as ActivityHistoryDoc;
  if (doc.coupleId !== couple.id) {
    throw Errors.permissionDenied(
      "Эта запись не принадлежит вашей паре."
    );
  }

  await historyRef.delete();

  return { success: true };
});
