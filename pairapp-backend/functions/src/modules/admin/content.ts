import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { z } from "zod";
import { db, Collections } from "../../config/firebase";
import { requireAdmin } from "../../utils/auth";
import { parseOrThrow } from "../../utils/validation";
import { Errors } from "../../utils/errors";
import { ActivityDoc, QuizQuestionDoc, SUPPORTED_LANGUAGES } from "../../types";

/**
 * Раздел 23.1 ТЗ: "Встроенные активности — добавление, редактирование,
 * включение/выключение" и "Вопросы квизов — управление банком вопросов
 * (с локализацией)".
 */

const upsertBuiltinActivitySchema = z.object({
  id: z.string().min(1).optional(), // отсутствует → создание новой
  title: z.string().trim().min(1).max(120),
  description: z.string().trim().min(1).max(1000),
  category: z.string().trim().min(1).max(60),
  durationMinutes: z.number().int().positive().nullish(),
  budgetLevel: z.enum(["free", "low", "medium", "high"]),
  isActive: z.boolean().default(true),
});

export const upsertBuiltinActivity = onCall(async (request) => {
  requireAdmin(request);
  const input = parseOrThrow(upsertBuiltinActivitySchema, request.data);

  const ref = input.id
    ? db.collection(Collections.activities).doc(input.id)
    : db.collection(Collections.activities).doc();

  const doc: ActivityDoc = {
    id: ref.id,
    coupleId: null, // builtin — раздел 17.7 ТЗ
    title: input.title,
    description: input.description,
    category: input.category,
    durationMinutes: input.durationMinutes ?? null,
    budgetLevel: input.budgetLevel,
    source: "builtin",
    createdBy: null,
    isActive: input.isActive,
    createdAt: Timestamp.now(),
  };

  await ref.set(doc, { merge: true });
  return { activityId: ref.id };
});

const setActivityActiveSchema = z.object({
  activityId: z.string().min(1),
  isActive: z.boolean(),
});

export const setActivityActive = onCall(async (request) => {
  requireAdmin(request);
  const input = parseOrThrow(setActivityActiveSchema, request.data);

  const ref = db.collection(Collections.activities).doc(input.activityId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw Errors.notFound("Активность");
  }
  await ref.update({ isActive: input.isActive });
  return { success: true };
});

const localizedTextSchema = z.record(z.enum(SUPPORTED_LANGUAGES), z.string());

const upsertQuizQuestionSchema = z.object({
  id: z.string().min(1).optional(),
  category: z.string().trim().min(1).max(60),
  questionText: localizedTextSchema,
  answerType: z.enum(["text", "single_choice", "multi_choice"]),
  options: z
    .array(
      z.object({
        id: z.string().min(1),
        text: localizedTextSchema,
      })
    )
    .nullish(),
  language: z.enum(SUPPORTED_LANGUAGES).nullish(),
  isActive: z.boolean().default(true),
});

export const upsertQuizQuestion = onCall(async (request) => {
  requireAdmin(request);
  const input = parseOrThrow(upsertQuizQuestionSchema, request.data);

  if (
    (input.answerType === "single_choice" || input.answerType === "multi_choice") &&
    (!input.options || input.options.length === 0)
  ) {
    throw Errors.invalidArgument(
      "Для single_choice/multi_choice вопросов обязателен список options."
    );
  }

  const ref = input.id
    ? db.collection(Collections.quizQuestions).doc(input.id)
    : db.collection(Collections.quizQuestions).doc();

  const doc: QuizQuestionDoc = {
    id: ref.id,
    category: input.category,
    questionText: input.questionText,
    answerType: input.answerType,
    options: input.options ?? null,
    language: input.language ?? null,
    isDefault: true,
    isActive: input.isActive,
    createdAt: Timestamp.now(),
  };

  await ref.set(doc, { merge: true });
  return { questionId: ref.id };
});

const setQuizQuestionActiveSchema = z.object({
  questionId: z.string().min(1),
  isActive: z.boolean(),
});

export const setQuizQuestionActive = onCall(async (request) => {
  requireAdmin(request);
  const input = parseOrThrow(setQuizQuestionActiveSchema, request.data);

  const ref = db.collection(Collections.quizQuestions).doc(input.questionId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw Errors.notFound("Вопрос квиза");
  }
  await ref.update({ isActive: input.isActive });
  return { success: true };
});
