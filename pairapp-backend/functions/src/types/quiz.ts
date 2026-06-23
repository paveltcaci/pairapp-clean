import {
  FirestoreTimestamp,
  PartnerSlot,
  QuizAnswerType,
  QuizSessionStatus,
  SupportedLanguage,
} from "./common";

/** Локализованный текст — словарь "код языка → строка". */
export type LocalizedText = Partial<Record<SupportedLanguage, string>>;

export interface QuizOption {
  id: string;
  text: LocalizedText;
}

/**
 * Коллекция `quiz_questions` (раздел 17.11 ТЗ).
 */
export interface QuizQuestionDoc {
  id: string;
  category: string;
  questionText: LocalizedText;
  answerType: QuizAnswerType;
  options: QuizOption[] | null;
  /** null — доступен на всех языках MVP. */
  language: SupportedLanguage | null;
  isDefault: boolean;
  isActive: boolean;
  createdAt: FirestoreTimestamp;
}

/**
 * Коллекция `quiz_sessions`.
 *
 * ВАЖНО: здесь больше НЕ храним partnerAAnswers / partnerBAnswers.
 * Ответы лежат в отдельной коллекции `quiz_answers`, чтобы партнёр
 * не мог прочитать ответы второго до завершения квиза обоими.
 */
export interface QuizSessionDoc {
  id: string;
  coupleId: string;
  category: string;
  createdBy: string;
  status: QuizSessionStatus;
  partnerAId: string;
  partnerBId: string;
  partnerACompletedAt: FirestoreTimestamp | null;
  partnerBCompletedAt: FirestoreTimestamp | null;
  score: QuizScore | null;
  questionIds: string[];
  createdAt: FirestoreTimestamp;
  completedAt: FirestoreTimestamp | null;
}

/**
 * Коллекция `quiz_answers`.
 * Один документ = ответы одного пользователя в одной quiz session.
 * documentId формируем детерминированно: `${sessionId}_${uid}`.
 */
export interface QuizAnswerDoc {
  id: string;
  sessionId: string;
  coupleId: string;
  userId: string;
  slot: PartnerSlot;
  answers: Record<string, QuizAnswerValue>;
  completedAt: FirestoreTimestamp;
  createdAt: FirestoreTimestamp;
}

export type QuizAnswerValue = string | string[];

export interface QuizScore {
  matchCount: number;
  totalCount: number;
  /** 0..100, округлено. */
  percentage: number;
}

/** Поэтапная разбивка совпадений вопроса для экрана результата. */
export type QuestionMatchLevel = "match" | "close" | "mismatch";

export interface QuizResultItem {
  questionId: string;
  questionText: LocalizedText;
  partnerAAnswer: QuizAnswerValue;
  partnerBAnswer: QuizAnswerValue;
  matchLevel: QuestionMatchLevel;
}

export interface StartQuizSessionInput {
  category: string;
  /** Количество вопросов в сессии; если не задано — берётся дефолт модуля. */
  questionCount?: number;
}

export interface SubmitQuizAnswersInput {
  sessionId: string;
  answers: Record<string, QuizAnswerValue>;
}