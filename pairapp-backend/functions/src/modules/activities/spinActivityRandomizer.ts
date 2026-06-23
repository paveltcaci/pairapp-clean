import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, spinActivitySchema } from "../../utils/validation";
import { getActiveCoupleOrThrow } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { ActivityDoc, SpinActivityInput } from "../../types";

/**
 * spinActivityRandomizer (раздел 11.2, 18 ТЗ): "Пользователь открывает
 * экран «Чем займёмся?», опционально выбирает фильтр по категории,
 * нажимает «Выбрать случайно», видит карточку".
 *
 * Источник пула — встроенные активности (coupleId == null) ОБЪЕДИНЁННЫЕ
 * с пользовательскими идеями этой конкретной пары (раздел 11.3 ТЗ:
 * "Пользовательские идеи участвуют в рандомайзере наравне со встроенными").
 *
 * Это callable-функция (не просто Firestore-запрос с клиента), потому
 * что: 1) объединение двух источников (coupleId == null OR coupleId ==
 * X) Firestore не поддерживает в одном where-запросе без composite
 * fan-out на клиенте; 2) если в будущем понадобится взвешенный выбор
 * (например, не показывать повторно недавно принятые активности),
 * это меняется в одном месте на backend.
 */
export const spinActivityRandomizer = onCall<SpinActivityInput>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(spinActivitySchema, request.data);
    const { couple } = await getActiveCoupleOrThrow(uid);

    let builtinQuery = db
      .collection(Collections.activities)
      .where("coupleId", "==", null)
      .where("isActive", "==", true);
    let coupleQuery = db
      .collection(Collections.activities)
      .where("coupleId", "==", couple.id)
      .where("isActive", "==", true);

    if (input.category) {
      builtinQuery = builtinQuery.where("category", "==", input.category);
      coupleQuery = coupleQuery.where("category", "==", input.category);
    }

    const [builtinSnap, coupleSnap] = await Promise.all([
      builtinQuery.get(),
      coupleQuery.get(),
    ]);

    const pool: ActivityDoc[] = [
      ...builtinSnap.docs.map((d) => d.data() as ActivityDoc),
      ...coupleSnap.docs.map((d) => d.data() as ActivityDoc),
    ];

    if (pool.length === 0) {
      throw Errors.notFound("Активности по выбранному фильтру");
    }

    const chosen = pool[Math.floor(Math.random() * pool.length)];
    return { activity: chosen };
  }
);

/**
 * acceptActivity — фиксирует выбор в activity_history (раздел 17.8 ТЗ).
 * Не выделена отдельной строкой в разделе 18 (там только
 * spinActivityRandomizer), но необходима: раздел 11.2 ТЗ описывает кнопку
 * «Принять», и раздел 17.8 ТЗ явно определяет коллекцию для истории
 * принятых активностей — без отдельного вызова "принятия" эта коллекция
 * никогда не наполнялась бы (спин — это просто показ кандидата, не выбор).
 */
export const acceptActivity = onCall<{ activityId: string }>(async (request) => {
  const uid = requireAuth(request);
  const activityId = request.data?.activityId;
  if (!activityId || typeof activityId !== "string") {
    throw Errors.invalidArgument("activityId обязателен.");
  }
  const { couple } = await getActiveCoupleOrThrow(uid);

  const activitySnap = await db
    .collection(Collections.activities)
    .doc(activityId)
    .get();
  if (!activitySnap.exists) {
    throw Errors.notFound("Активность");
  }
  const activity = activitySnap.data() as ActivityDoc;
  if (activity.coupleId !== null && activity.coupleId !== couple.id) {
    throw Errors.permissionDenied("Эта активность недоступна для вашей пары.");
  }

  const historyRef = db.collection(Collections.activityHistory).doc();
  await historyRef.set({
    id: historyRef.id,
    coupleId: couple.id,
    activityId,
    chosenBy: uid,
    chosenAt: Timestamp.now(),
  });

  return { success: true };
});
