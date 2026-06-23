import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, spinChoreSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import {
  CHORE_FAIRNESS_WINDOW,
  ChoreSpinDoc,
  ChoreTaskDoc,
  SpinChoreInput,
} from "../../types";

/**
 * Раздел 12.2 ТЗ: "Рандомайзер не является полностью случайным. Для
 * каждой задачи хранится история последних выборов. Если один партнёр
 * выпадал два раза подряд — на третий раз вероятность второго партнёра
 * повышается. Это исключает систематическое «невезение» одного из
 * партнёров."
 *
 * Алгоритм (детерминированная интерпретация качественного описания ТЗ):
 * 1. Берём последние CHORE_FAIRNESS_WINDOW спинов для этой задачи.
 * 2. Считаем streak — сколько раз ПОДРЯД (с конца истории) выпадал один
 *    и тот же партнёр.
 * 3. Базовый вес каждого партнёра — 1 (равная вероятность 50/50).
 * 4. Если streak >= 2 для партнёра X, вес партнёра X уменьшается, а вес
 *    второго партнёра увеличивается пропорционально streak — но не до
 *    100% (раздел 12.2 говорит "повышается", а не "гарантируется"), чтобы
 *    сохранить элемент случайности.
 *
 * Формула веса второго партнёра: 1 + streak * 0.5, у партнёра со streak —
 * вес остаётся 1. Например, streak=2 → веса {streak-партнёр: 1, другой: 2}
 * → вероятность другого партнёра ~67%. streak=4 (на случай очень редких
 * задач) → веса {1, 3} → ~75%, но никогда не 100%.
 */
function computeFairWeights(
  recentSelections: string[], // от старых к новым, ID пользователей
  partnerAId: string,
  partnerBId: string
): { weightA: number; weightB: number; streak: number; streakUser: string | null } {
  if (recentSelections.length === 0) {
    return { weightA: 1, weightB: 1, streak: 0, streakUser: null };
  }

  const last = recentSelections[recentSelections.length - 1];
  let streak = 1;
  for (let i = recentSelections.length - 2; i >= 0; i--) {
    if (recentSelections[i] === last) {
      streak++;
    } else {
      break;
    }
  }

  if (streak < 2) {
    return { weightA: 1, weightB: 1, streak, streakUser: last };
  }

  const boost = 1 + streak * 0.5;
  if (last === partnerAId) {
    return { weightA: 1, weightB: boost, streak, streakUser: last };
  }
  if (last === partnerBId) {
    return { weightA: boost, weightB: 1, streak, streakUser: last };
  }
  // last не совпадает ни с одним текущим партнёром пары — например,
  // история спинов осталась от прошлого состава пары (после
  // leaveCouple/joinCoupleByInviteCode partnerAId/partnerBId не
  // переиспользуются для новой пары, но защищаемся явно, а не молча
  // полагаемся на "не A значит B").
  return { weightA: 1, weightB: 1, streak: 0, streakUser: null };
}

function weightedPick(
  partnerAId: string,
  partnerBId: string,
  weightA: number,
  weightB: number
): string {
  const total = weightA + weightB;
  return Math.random() * total < weightA ? partnerAId : partnerBId;
}

export const spinChoreRandomizer = onCall<SpinChoreInput>(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(spinChoreSchema, request.data);
  const { couple } = await getActiveCoupleOrThrow(uid);

  if (!couple.partnerBId) {
    throw Errors.failedPrecondition(
      "Бытовой рандомайзер доступен только когда оба партнёра подключены."
    );
  }

  const taskSnap = await db.collection(Collections.choreTasks).doc(input.choreTaskId).get();
  if (!taskSnap.exists) {
    throw Errors.notFound("Бытовая задача");
  }
  const task = taskSnap.data() as ChoreTaskDoc;
  if (task.coupleId !== couple.id) {
    throw Errors.permissionDenied("Эта задача принадлежит другой паре.");
  }
  if (!task.isActive) {
    throw Errors.failedPrecondition("Эта задача отключена.");
  }

  const recentSpinsSnap = await db
    .collection(Collections.choreSpins)
    .where("choreTaskId", "==", input.choreTaskId)
    .orderBy("spunAt", "desc")
    .limit(CHORE_FAIRNESS_WINDOW)
    .get();

  // orderBy desc → переворачиваем, чтобы получить хронологический порядок
  // (от старых к новым), как того требует computeFairWeights.
  const recentSelections = recentSpinsSnap.docs
    .map((d) => (d.data() as ChoreSpinDoc).selectedUserId)
    .reverse();

  const { weightA, weightB } = computeFairWeights(
    recentSelections,
    couple.partnerAId,
    couple.partnerBId
  );

  const selectedUserId = weightedPick(
    couple.partnerAId,
    couple.partnerBId,
    weightA,
    weightB
  );

  const partnerARecentCount = recentSelections.filter(
    (id) => id === couple.partnerAId
  ).length;
  const partnerBRecentCount = recentSelections.filter(
    (id) => id === couple.partnerBId
  ).length;

  const spinRef = db.collection(Collections.choreSpins).doc();
  const spinDoc: ChoreSpinDoc = {
    id: spinRef.id,
    choreTaskId: input.choreTaskId,
    coupleId: couple.id,
    selectedUserId,
    partnerARecentCount,
    partnerBRecentCount,
    spunAt: Timestamp.now(),
  };
  await spinRef.set(spinDoc);

  return { selectedUserId, spinId: spinRef.id };
});
