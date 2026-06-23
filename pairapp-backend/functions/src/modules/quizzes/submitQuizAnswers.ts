import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, submitQuizAnswersSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { sendPushToUser } from "../../utils/push";
import {
  QuestionMatchLevel,
  QuizAnswerDoc,
  QuizAnswerValue,
  QuizSessionDoc,
  SubmitQuizAnswersInput,
} from "../../types";

/**
 * Раздел 13.3 ТЗ: "зелёный — совпало, жёлтый — близко, красный —
 * расходятся".
 */
function compareAnswers(
  a: QuizAnswerValue,
  b: QuizAnswerValue
): QuestionMatchLevel {
  if (Array.isArray(a) || Array.isArray(b)) {
    const setA = new Set(Array.isArray(a) ? a : [a]);
    const setB = new Set(Array.isArray(b) ? b : [b]);
    const intersection = [...setA].filter((v) => setB.has(v));

    if (intersection.length === 0) return "mismatch";

    if (intersection.length === setA.size && intersection.length === setB.size) {
      return "match";
    }

    return "close";
  }

  const normalize = (v: string) => v.trim().toLowerCase();

  return normalize(a as string) === normalize(b as string)
    ? "match"
    : "mismatch";
}

function answerDocId(sessionId: string, uid: string): string {
  return `${sessionId}_${uid}`;
}

/**
 * submitQuizAnswers.
 *
 * Ответы больше не пишутся в `quiz_sessions`.
 * Они хранятся в `quiz_answers`.
 *
 * До завершения квиза пользователь читает только свой документ ответов.
 * После завершения обоими сторонами оба партнёра смогут читать оба ответа
 * для экрана результата.
 */
export const submitQuizAnswers = onCall<SubmitQuizAnswersInput>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(submitQuizAnswersSchema, request.data);
    const { couple } = await getActiveCoupleOrThrow(uid);
    const { selfSlot, partnerId } = resolvePartner(couple, uid);

    const sessionRef = db.collection(Collections.quizSessions).doc(input.sessionId);

    const selfAnswerRef = db
      .collection(Collections.quizAnswers)
      .doc(answerDocId(input.sessionId, uid));

    const partnerAnswerRef = partnerId
      ? db
          .collection(Collections.quizAnswers)
          .doc(answerDocId(input.sessionId, partnerId))
      : null;

    const outcome = await db.runTransaction(async (tx) => {
      /*
       * ВАЖНО:
       * В Firestore transaction сначала делаем все чтения,
       * потом все записи.
       */
      const sessionSnap = await tx.get(sessionRef);
      const selfAnswerSnap = await tx.get(selfAnswerRef);
      const partnerAnswerSnap = partnerAnswerRef
        ? await tx.get(partnerAnswerRef)
        : null;

      if (!sessionSnap.exists) {
        throw Errors.notFound("Сессия квиза");
      }

      const session = sessionSnap.data() as QuizSessionDoc;

      if (session.coupleId !== couple.id) {
        throw Errors.permissionDenied("Эта сессия квиза принадлежит другой паре.");
      }

      if (session.status === "completed") {
        throw Errors.failedPrecondition("Этот квиз уже завершён.");
      }

      if (selfAnswerSnap.exists) {
        throw Errors.failedPrecondition("Вы уже отправили ответы для этой сессии.");
      }

      const missingQuestions = session.questionIds.filter(
        (qid) => !(qid in input.answers)
      );

      if (missingQuestions.length > 0) {
        throw Errors.invalidArgument(
          `Не получены ответы на вопросы: ${missingQuestions.join(", ")}.`
        );
      }

      const now = Timestamp.now();

      const selfAnswerDoc: QuizAnswerDoc = {
        id: selfAnswerRef.id,
        sessionId: input.sessionId,
        coupleId: couple.id,
        userId: uid,
        slot: selfSlot,
        answers: input.answers,
        completedAt: now,
        createdAt: now,
      };

      const patch: Record<string, unknown> = {};

      if (selfSlot === "A") {
        patch.partnerACompletedAt = now;
      } else {
        patch.partnerBCompletedAt = now;
      }

      const partnerAnswer = partnerAnswerSnap?.exists
        ? (partnerAnswerSnap.data() as QuizAnswerDoc)
        : null;

      const bothCompleted = !!partnerAnswer;

      tx.set(selfAnswerRef, selfAnswerDoc);

      if (!bothCompleted) {
        patch.status = selfSlot === "A" ? "waiting_partner_b" : "waiting_partner_a";
        tx.update(sessionRef, patch);

        return {
          bothCompleted: false,
          score: null,
        };
      }

      const partnerAAnswers =
        selfSlot === "A" ? input.answers : partnerAnswer!.answers;

      const partnerBAnswers =
        selfSlot === "B" ? input.answers : partnerAnswer!.answers;

      let matchCount = 0;

      for (const qid of session.questionIds) {
        const level = compareAnswers(partnerAAnswers[qid], partnerBAnswers[qid]);

        if (level === "match") {
          matchCount++;
        }
      }

      const totalCount = session.questionIds.length;
      const percentage = Math.round((matchCount / totalCount) * 100);
      const score = { matchCount, totalCount, percentage };

      patch.status = "completed";
      patch.completedAt = now;
      patch.score = score;

      tx.update(sessionRef, patch);

      return {
        bothCompleted: true,
        score,
      };
    });

    if (partnerId && outcome.bothCompleted) {
      await sendPushToUser(partnerId, "quizCompleted", {
        titleKey: "push.quizCompleted.title",
        bodyKey: "push.quizCompleted.body",
        data: { sessionId: input.sessionId },
      });
    }

    return outcome;
  }
);