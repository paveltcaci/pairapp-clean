/**
 * Общие типы, enum-ы и константы, используемые во всём backend.
 * Источник истины — раздел 17 ТЗ (Схема базы данных).
 */

import { Timestamp } from "firebase-admin/firestore";

/** Поддерживаемые языки интерфейса в MVP (раздел 4.2 ТЗ). */
export const SUPPORTED_LANGUAGES = ["ru", "en"] as const;
export type SupportedLanguage = (typeof SUPPORTED_LANGUAGES)[number];

/** Языки, зарезервированные под будущие версии (раздел 4.3 ТЗ) — не активны в MVP. */
export const FUTURE_LANGUAGES = ["ro", "uk", "es", "de", "fr"] as const;

export type Gender = "male" | "female" | "other" | "prefer_not_to_say";

export type CoupleStatus = "active" | "disconnected" | "blocked" | "deleted";

export type IssueStatus =
  | "open"
  | "in_discussion"
  | "agreement_proposed"
  | "agreed"
  | "solved"
  | "reopened"
  | "archived";

export type IssueMessageType =
  | "comment"
  | "objection"
  | "solution"
  | "agreement"
  | "checkin"
  | "reopen";

/** Категории проблем (раздел 8.4 ТЗ). */
export const ISSUE_CATEGORIES = [
  "time_together",
  "communication",
  "household",
  "money",
  "jealousy",
  "intimacy",
  "support",
  "family",
  "future_plans",
  "other",
] as const;
export type IssueCategory = (typeof ISSUE_CATEGORIES)[number];

/** Чувства, которые можно отметить при создании проблемы (раздел 8.4 ТЗ). */
export const ISSUE_FEELINGS = [
  "sadness",
  "loneliness",
  "anger",
  "anxiety",
  "tiredness",
  "misunderstanding",
  "other",
] as const;
export type IssueFeeling = (typeof ISSUE_FEELINGS)[number];

export type AgreementStatus =
  | "proposed"
  | "accepted_by_one"
  | "accepted_by_both"
  | "active"
  | "failed"
  | "completed"
  | "archived";

export type CheckinAnswer = "yes" | "partially" | "no";
export type CheckinStatus = "pending" | "partial" | "completed";
export type CheckinResult = "success" | "partial" | "failed";

/** Допустимые интервалы проверки договорённости, в днях (раздел 9.4 ТЗ). 0 = произвольная дата. */
export const CHECK_INTERVAL_DAYS = [1, 3, 7, 14, 30] as const;

export type BudgetLevel = "free" | "low" | "medium" | "high";
export type ActivitySource = "builtin" | "user_created";

export type QuizAnswerType = "text" | "single_choice" | "multi_choice";
export type QuizSessionStatus =
  | "waiting_partner_a"
  | "waiting_partner_b"
  | "both_answered"
  | "completed";

export type RelationshipEventType = "anniversary" | "milestone" | "custom";

export type ReportTargetType = "issue" | "message" | "profile";
export type ReportReason =
  | "abuse"
  | "threats"
  | "sexual_content"
  | "manipulation"
  | "spam"
  | "other";
export type ReportStatus = "pending" | "reviewed" | "resolved" | "dismissed";

export type SubscriptionPlatform = "android" | "ios";
export type SubscriptionStatus = "active" | "expired" | "cancelled" | "trial";

/** Roles used for the admin panel / custom claims. */
export type AppRole = "user" | "admin";

/**
 * Идентификатор партнёра внутри пары — используется везде, где нужно
 * различать "A" / "B" без привязки к конкретному userId.
 */
export type PartnerSlot = "A" | "B";

export type FirestoreTimestamp = Timestamp;
