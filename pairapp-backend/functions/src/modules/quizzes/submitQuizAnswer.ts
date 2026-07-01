import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { z } from "zod";
import { QuizRoundDoc, QuizRoundStatus } from "./createQuizRound";

// ── Validation schema ────────────────────────────────────────────────────────

const submitQuizAnswerSchema = z.object({
  roundId: z.string().trim().min(1).max(128),
  answer: z.string().trim().min(1).max(2000),
});

export type SubmitQuizAnswerInput = z.infer<typeof submitQuizAnswerSchema>;

// ── Cloud Function ──────────────────────────────────────────────────────────

const QUIZ_ROUNDS = "quiz_rounds";

/**
 * submitQuizAnswer — Квизы V1.
 *
 * Пишет ответ текущего пользователя в документ раунда.
 * Если оба партнёра ответили → status = "completed", вычисляем matched.
 * Ответы в поле `answers` хранятся по uid — клиент не должен раскрывать
 * ответ партнёра пока status != "completed".
 */
export const submitQuizAnswer = onCall<SubmitQuizAnswerInput>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(submitQuizAnswerSchema, request.data);

    const { couple } = await getActiveCoupleOrThrow(uid);
    resolvePartner(couple, uid); // Guard: убедиться что uid в паре

    const roundRef = db.collection(QUIZ_ROUNDS).doc(input.roundId);

    const outcome = await db.runTransaction(async (tx) => {
      const snap = await tx.get(roundRef);

      if (!snap.exists) {
        throw Errors.notFound("Раунд квиза");
      }

      const round = snap.data() as QuizRoundDoc;

      if (round.coupleId !== couple.id) {
        throw Errors.permissionDenied("Этот раунд принадлежит другой паре.");
      }

      if (round.status === "completed") {
        throw Errors.failedPrecondition("Раунд уже завершён.");
      }

      if (round.answers[uid] !== undefined) {
        throw Errors.failedPrecondition("Вы уже ответили на этот вопрос.");
      }

      const now = Timestamp.now();

      const newAnswers = { ...round.answers, [uid]: input.answer };
      const newAnsweredAt = { ...round.answeredAt, [uid]: now };

      // Определяем партнёра — тот uid в паре который != текущий
      const partnerUid =
        round.partnerAId === uid ? round.partnerBId : round.partnerAId;

      const partnerAnswered = round.answers[partnerUid] !== undefined;

      let newStatus: QuizRoundStatus;
      let matched: boolean | null = null;
      let completedAt: Timestamp | null = null;

      if (partnerAnswered) {
        // Оба ответили
        newStatus = "completed";
        completedAt = now;

        if (round.answerType === "choice") {
          const myAnswer = input.answer.trim().toLowerCase();
          const partnerAnswer = round.answers[partnerUid].trim().toLowerCase();
          matched = myAnswer === partnerAnswer;
        } else {
          matched = null; // open_text — нет правильного/неправильного
        }
      } else {
        newStatus = "waiting_partner";
      }

      tx.update(roundRef, {
        answers: newAnswers,
        answeredAt: newAnsweredAt,
        status: newStatus,
        matched,
        completedAt,
      });

      return {
        bothAnswered: partnerAnswered,
        matched,
        status: newStatus,
      };
    });

    return outcome;
  }
);
