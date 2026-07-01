import { z } from "zod";
import {
  CHECK_INTERVAL_DAYS,
  ISSUE_CATEGORIES,
  ISSUE_FEELINGS,
  SUPPORTED_LANGUAGES,
} from "../types/common";
import { Errors } from "./errors";

/** Используется при регистрации (раздел 5.2 ТЗ). */
export const registerUserSchema = z.object({
  displayName: z.string().trim().min(1).max(60),
  gender: z.enum(["male", "female", "other", "prefer_not_to_say"]),
  birthDate: z.string().refine((v) => !Number.isNaN(Date.parse(v)), {
    message: "birthDate должен быть валидной ISO-датой.",
  }),
  language: z.enum(SUPPORTED_LANGUAGES),
  acceptedTermsOfUse: z.literal(true, {
    errorMap: () => ({ message: "Необходимо принять Terms of Use." }),
  }),
  acceptedPrivacyPolicy: z.literal(true, {
    errorMap: () => ({ message: "Необходимо принять Privacy Policy." }),
  }),
});

export const joinCoupleSchema = z.object({
  inviteCode: z.string().trim().min(4).max(32),
});

export const updateRelationshipStartDateSchema = z.object({
  date: z.string().refine((v) => !Number.isNaN(Date.parse(v))),
});

export const createIssueSchema = z.object({
  title: z.string().trim().min(1).max(200),
  description: z.string().trim().max(4000).nullish(),
  feelings: z.array(z.enum(ISSUE_FEELINGS)).max(ISSUE_FEELINGS.length).optional(),
  importanceLevel: z.number().int().min(1).max(5),
  desiredOutcome: z.string().trim().max(1000).nullish(),
  category: z.enum(ISSUE_CATEGORIES),
});

export const updateIssueSchema = z.object({
  issueId: z.string().min(1),
  title: z.string().trim().min(1).max(200).optional(),
  description: z.string().trim().max(4000).nullish(),
  feelings: z.array(z.enum(ISSUE_FEELINGS)).optional(),
  importanceLevel: z.number().int().min(1).max(5).optional(),
  desiredOutcome: z.string().trim().max(1000).nullish(),
  category: z.enum(ISSUE_CATEGORIES).optional(),
});

export const createIssueMessageSchema = z.object({
  issueId: z.string().min(1),
  type: z.enum([
    "comment",
    "objection",
    "solution",
    "agreement",
    "checkin",
    "reopen",
  ]),
  text: z.string().trim().min(1).max(4000),
});

export const solveIssueSchema = z.object({
  issueId: z.string().min(1),
});

export const reopenIssueSchema = z.object({
  issueId: z.string().min(1),
  reason: z.string().trim().max(2000).optional(),
});

const checkIntervalEnum = z.union([
  z.literal(CHECK_INTERVAL_DAYS[0]),
  z.literal(CHECK_INTERVAL_DAYS[1]),
  z.literal(CHECK_INTERVAL_DAYS[2]),
  z.literal(CHECK_INTERVAL_DAYS[3]),
  z.literal(CHECK_INTERVAL_DAYS[4]),
]);

export const proposeAgreementSchema = z
  .object({
    issueId: z.string().min(1).nullish(),
    title: z.string().trim().min(1).max(200),
    description: z.string().trim().max(2000).nullish(),
    checkIntervalDays: checkIntervalEnum.nullish(),
    customCheckDate: z
      .string()
      .refine((v) => !Number.isNaN(Date.parse(v)))
      .nullish(),
  })
  .refine((v) => v.checkIntervalDays != null || v.customCheckDate != null, {
    message: "Укажите checkIntervalDays или customCheckDate.",
  });

export const acceptAgreementSchema = z.object({
  agreementId: z.string().min(1),
});

export const submitCheckinAnswerSchema = z.object({
  checkinId: z.string().min(1),
  answer: z.enum(["yes", "partially", "no"]),
});

export const createActivitySchema = z.object({
  title: z.string().trim().min(1).max(120),
  description: z.string().trim().min(1).max(1000),
  category: z.string().trim().min(1).max(60),
  durationMinutes: z.number().int().positive().nullish(),
  budgetLevel: z.enum(["free", "low", "medium", "high"]),
});

export const spinActivitySchema = z.object({
  category: z.string().trim().min(1).max(60).nullish(),
});

export const createChoreTaskSchema = z.object({
  title: z.string().trim().min(1).max(120),
  description: z.string().trim().max(1000).nullish(),
  emoji: z.string().trim().max(8).optional(),
  category: z.string().trim().max(60).optional(),
  intensity: z.enum(["easy", "medium", "annoying"]).optional(),
  estimatedMinutes: z.number().int().min(1).max(480).nullish(),
});

export const spinChoreSchema = z.object({
  choreTaskId: z.string().min(1),
});

export const softDeleteChoreTaskSchema = z.object({
  choreTaskId: z.string().min(1),
});

export const startQuizSessionSchema = z.object({
  category: z.string().trim().min(1).max(60),
  questionCount: z.number().int().min(1).max(50).optional(),
});

export const submitQuizAnswersSchema = z.object({
  sessionId: z.string().min(1),
  answers: z.record(z.string(), z.union([z.string(), z.array(z.string())])),
});

export const createReportSchema = z.object({
  targetType: z.enum(["issue", "message", "profile"]),
  targetId: z.string().min(1),
  reason: z.enum([
    "abuse",
    "threats",
    "sexual_content",
    "manipulation",
    "spam",
    "other",
  ]),
  comment: z.string().trim().max(2000).nullish(),
});

export const blockUserSchema = z.object({
  reportId: z.string().min(1).nullish(),
});

export const updateFcmTokenSchema = z.object({
  fcmToken: z.string().min(1),
});

export const removeFcmTokenSchema = z.object({
  fcmToken: z.string().min(1),
});

export const saveActivityIdeaSnapshotSchema = z.object({
  localIdeaId: z.string().trim().min(1).max(60),
  title: z.string().trim().min(1).max(200),
  description: z.string().trim().min(1).max(1000),
  emoji: z.string().trim().min(1).max(10),
  categories: z.array(z.string().trim().min(1).max(60)).min(1).max(10),
  durationMinutes: z.number().int().positive().nullish(),
  budgetLevel: z.enum(["free", "low", "medium"]),
  locationType: z.enum(["home", "outside", "any"]),
  vibe: z.enum(["calm", "fun", "romantic", "deep", "spontaneous", "cozy"]),
  preparation: z.string().trim().max(500).nullish(),
});

export const removeSavedActivityIdeaSchema = z.object({
  historyId: z.string().trim().min(1),
});

// ── Wishlist ────────────────────────────────────────────────────────────────

export const createWishlistItemSchema = z.object({
  title: z.string().trim().min(1).max(200),
  description: z.string().trim().max(2000).nullish(),
  emoji: z.string().trim().max(10).optional(),
  category: z.string().trim().max(60).optional(),
  priority: z.enum(["low", "medium", "high"]).optional(),
  budgetLevel: z.enum(["free", "low", "medium", "high"]).optional(),
});

export const updateWishlistItemStatusSchema = z.object({
  itemId: z.string().min(1),
  status: z.enum(["active", "done", "archived"]),
});

export const deleteWishlistItemSchema = z.object({
  itemId: z.string().min(1),
});

/**
 * Прогоняет данные через Zod-схему и конвертирует ошибку валидации
 * в стандартный HttpsError('invalid-argument', ...).
 */
export function parseOrThrow<T extends z.ZodTypeAny>(
  schema: T,
  data: unknown
): z.infer<T> {
  const result = schema.safeParse(data);
  if (!result.success) {
    const message = result.error.issues
      .map((i) => `${i.path.join(".") || "(root)"}: ${i.message}`)
      .join("; ");
    throw Errors.invalidArgument(message);
  }
  return result.data;
}
