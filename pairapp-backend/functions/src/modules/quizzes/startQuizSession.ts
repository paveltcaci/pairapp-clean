import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, startQuizSessionSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { sendPushToUser } from "../../utils/push";
import { QuizQuestionDoc, QuizSessionDoc, StartQuizSessionInput } from "../../types";

const DEFAULT_QUESTION_COUNT = 10;

/**
 * startQuizSession (раздел 13.1, 18 ТЗ): "Один партнёр выбирает категорию
 * и запускает квиз."
 *
 * Раздел 17.11 ТЗ: вопрос может быть language-специфичным (`language`
 * не null) или доступным на всех языках MVP (`language: null`). При
 * выборке вопросов мы не фильтруем по языку пользователя — раздел 4.1 ТЗ
 * чётко разделяет "язык интерфейса" (кнопки/подсказки) от "контента,
 * который вводят партнёры" (не переводится), а вопросы квиза — это
 * системный контент с готовым переводом на оба языка MVP внутри
 * questionText (Map<язык, текст>), поэтому язык конкретного вопроса не
 * блокирует его участие — клиент сам выбирает нужный ключ из questionText
 * при отображении.
 */
export const startQuizSession = onCall<StartQuizSessionInput>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(startQuizSessionSchema, request.data);
    const { couple } = await getActiveCoupleOrThrow(uid);
    const { partnerId } = resolvePartner(couple, uid);

    if (!partnerId) {
      throw Errors.failedPrecondition(
        "Квиз доступен только когда оба партнёра подключены."
      );
    }

    const questionCount = input.questionCount ?? DEFAULT_QUESTION_COUNT;

    const questionsSnap = await db
      .collection(Collections.quizQuestions)
      .where("category", "==", input.category)
      .where("isActive", "==", true)
      .get();

    if (questionsSnap.empty) {
      throw Errors.notFound("Вопросы для выбранной категории");
    }

    // Случайная выборка questionCount вопросов из пула (без повторов).
    const pool = questionsSnap.docs.map((d) => d.data() as QuizQuestionDoc);
    const shuffled = [...pool].sort(() => Math.random() - 0.5);
    const selected = shuffled.slice(0, Math.min(questionCount, shuffled.length));
    const questionIds = selected.map((q) => q.id);

    const sessionRef = db.collection(Collections.quizSessions).doc();
    const now = Timestamp.now();
    const sessionDoc: QuizSessionDoc = {
      id: sessionRef.id,
      coupleId: couple.id,
      category: input.category,
      createdBy: uid,
      status: "waiting_partner_a",
      partnerAId: couple.partnerAId,
      // couple.partnerBId гарантированно не null здесь — partnerId выше
      // уже подтвердил, что у пары оба партнёра подключены.
      partnerBId: couple.partnerBId as string,
      partnerACompletedAt: null,
      partnerBCompletedAt: null,
      score: null,
      questionIds,
      createdAt: now,
      completedAt: null,
    };

    await sessionRef.set(sessionDoc);

    await sendPushToUser(partnerId, "quizStarted", {
      titleKey: "push.quizStarted.title",
      bodyKey: "push.quizStarted.body",
      data: { sessionId: sessionRef.id },
    });

    return { sessionId: sessionRef.id, questionIds };
  }
);
