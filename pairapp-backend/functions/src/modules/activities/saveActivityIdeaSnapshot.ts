import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, saveActivityIdeaSnapshotSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow } from "../../utils/couple-context";

/**
 * saveActivityIdeaSnapshot — сохраняет snapshot локальной builtin-идеи
 * в activity_history без прямой записи с клиента.
 *
 * Клиент хранит большой локальный список идей (local_builtin).
 * Эта CF позволяет "закрепить" выбранную идею для пары, записав её
 * snapshot в activity_history через Admin SDK.
 *
 * Дубликаты: если coupleId + localIdeaId уже существует — возвращаем
 * { alreadySaved: true } без ошибки.
 */
export const saveActivityIdeaSnapshot = onCall<unknown>(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(saveActivityIdeaSnapshotSchema, request.data);
  const { couple } = await getActiveCoupleOrThrow(uid);

  // Проверка дубликата по coupleId + localIdeaId
  const existingSnap = await db
    .collection(Collections.activityHistory)
    .where("coupleId", "==", couple.id)
    .where("localIdeaId", "==", input.localIdeaId)
    .limit(1)
    .get();

  if (!existingSnap.empty) {
    return { alreadySaved: true };
  }

  const historyRef = db.collection(Collections.activityHistory).doc();
  const now = Timestamp.now();

  await historyRef.set({
    id: historyRef.id,
    coupleId: couple.id,
    // null-поля для обратной совместимости с acceptActivity-контрактом
    activityId: null,
    chosenBy: null,
    chosenAt: null,
    // snapshot полей local idea
    source: "local_builtin",
    localIdeaId: input.localIdeaId,
    title: input.title,
    description: input.description,
    emoji: input.emoji,
    categories: input.categories,
    durationMinutes: input.durationMinutes ?? null,
    budgetLevel: input.budgetLevel,
    locationType: input.locationType,
    vibe: input.vibe,
    preparation: input.preparation ?? null,
    savedBy: uid,
    savedAt: now,
    createdAt: now,
  });

  return { success: true, historyId: historyRef.id };
});
