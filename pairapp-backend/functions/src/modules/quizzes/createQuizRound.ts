import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { z } from "zod";

// ── Validation schema ────────────────────────────────────────────────────────

const createQuizRoundSchema = z.object({
  /** Категория вопроса (строка из клиента). */
  category: z.string().trim().min(1).max(100),
  /** Локальный id вопроса из quiz_questions_data.dart. */
  questionId: z.string().trim().min(1).max(100),
  /** Текст вопроса — snapshot, чтобы не зависеть от client-side data. */
  questionText: z.string().trim().min(1).max(1000),
  /** Тип ответа. */
  answerType: z.enum(["open_text", "choice"]),
  /** Варианты ответа (только для choice). */
  options: z
    .array(
      z.object({
        id: z.string().trim().min(1).max(60),
        text: z.string().trim().min(1).max(200),
      })
    )
    .max(8)
    .optional()
    .nullable(),
});

export type CreateQuizRoundInput = z.infer<typeof createQuizRoundSchema>;

// ── Firestore document types ────────────────────────────────────────────────

/** Статус одного раунда (один вопрос — два партнёра). */
export type QuizRoundStatus =
  | "waiting_both"     // Никто ещё не ответил
  | "waiting_partner"  // Один ответил, ждём второго
  | "completed";       // Оба ответили → reveal

export interface QuizRoundOption {
  id: string;
  text: string;
}

export interface QuizRoundDoc {
  id: string;
  coupleId: string;
  createdBy: string;
  category: string;
  questionId: string;
  questionText: string;
  answerType: "open_text" | "choice";
  options: QuizRoundOption[] | null;
  /** uid → ответ пользователя. Пустой до ответов. */
  answers: Record<string, string>;
  /** uid → timestamp ответа. */
  answeredAt: Record<string, Timestamp>;
  status: QuizRoundStatus;
  /** Только для choice: true если ответы совпали. */
  matched: boolean | null;
  partnerAId: string;
  partnerBId: string;
  createdAt: Timestamp;
  completedAt: Timestamp | null;
}

// ── Collections helper ──────────────────────────────────────────────────────

const QUIZ_ROUNDS = "quiz_rounds";

// ── Cloud Function ──────────────────────────────────────────────────────────

/**
 * createQuizRound — Квизы V1.
 *
 * Один партнёр выбирает категорию, затем конкретный вопрос и запускает раунд.
 * Второй партнёр видит активный вопрос в реальном времени через Stream.
 * Пока оба не ответили — ответы не раскрываются на клиенте.
 */
export const createQuizRound = onCall<CreateQuizRoundInput>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(createQuizRoundSchema, request.data);

    const { couple } = await getActiveCoupleOrThrow(uid);
    const { partnerId } = resolvePartner(couple, uid);

    if (!partnerId) {
      throw Errors.failedPrecondition(
        "Квизы доступны только когда оба партнёра подключены."
      );
    }

    // Проверяем, нет ли уже активного раунда (waiting_both / waiting_partner).
    const activeSnap = await db
      .collection(QUIZ_ROUNDS)
      .where("coupleId", "==", couple.id)
      .where("status", "in", ["waiting_both", "waiting_partner"])
      .get();

    if (!activeSnap.empty) {
      throw Errors.failedPrecondition(
        "У вашей пары уже есть активный вопрос. Ответьте на него, прежде чем запускать новый."
      );
    }

    const roundRef = db.collection(QUIZ_ROUNDS).doc();
    const now = Timestamp.now();

    const roundDoc: QuizRoundDoc = {
      id: roundRef.id,
      coupleId: couple.id,
      createdBy: uid,
      category: input.category,
      questionId: input.questionId,
      questionText: input.questionText,
      answerType: input.answerType,
      options: input.options ?? null,
      answers: {},
      answeredAt: {},
      status: "waiting_both",
      matched: null,
      partnerAId: couple.partnerAId,
      partnerBId: couple.partnerBId as string,
      createdAt: now,
      completedAt: null,
    };

    await roundRef.set(roundDoc);

    return { roundId: roundRef.id };
  }
);
