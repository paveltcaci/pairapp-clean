import { FieldValue } from "firebase-admin/firestore";
import {
  AgreementStatus,
  CheckinAnswer,
  CheckinResult,
  CheckinStatus,
  FirestoreTimestamp,
} from "./common";

/**
 * Коллекция `agreements` (раздел 17.5 ТЗ).
 */
export interface AgreementDoc {
  id: string;
  coupleId: string;
  issueId: string | null;
  title: string;
  description: string | null;
  proposedBy: string;
  acceptedByPartnerA: boolean;
  acceptedByPartnerB: boolean;
  status: AgreementStatus;
  /** null означает "произвольная дата" — checkDate всё равно заполнен. */
  checkIntervalDays: number | null;
  checkDate: FirestoreTimestamp | null;
  createdAt: FirestoreTimestamp;
  updatedAt: FirestoreTimestamp | FieldValue;
}

export interface ProposeAgreementInput {
  issueId?: string | null;
  title: string;
  description?: string | null;
  /** Один из CHECK_INTERVAL_DAYS, либо null если ниже передана customCheckDate. */
  checkIntervalDays?: number | null;
  /** ISO-8601 дата — обязательна, если checkIntervalDays не задан. */
  customCheckDate?: string | null;
}

export interface AcceptAgreementInput {
  agreementId: string;
}

/**
 * Коллекция `checkins` (раздел 17.6 ТЗ).
 */
export interface CheckinDoc {
  id: string;
  agreementId: string;
  issueId: string | null;
  coupleId: string;
  scheduledAt: FirestoreTimestamp;
  partnerAAnswer: CheckinAnswer | null;
  partnerBAnswer: CheckinAnswer | null;
  partnerAAnsweredAt: FirestoreTimestamp | null;
  partnerBAnsweredAt: FirestoreTimestamp | null;
  status: CheckinStatus;
  result: CheckinResult | null;
  createdAt: FirestoreTimestamp;
  completedAt: FirestoreTimestamp | null;
  /**
   * Не предусмотрено разделом 17.6 ТЗ явно, но необходимо технически:
   * отметка, что push "пора проверить договорённость" уже отправлен —
   * защита от повторной отправки при следующем запуске scheduled-функции
   * createCheckin (она проходит по pending-чекинам каждый час).
   */
  notifiedAt: FirestoreTimestamp | null;
}

export interface SubmitCheckinAnswerInput {
  checkinId: string;
  answer: CheckinAnswer;
}

/**
 * Раздел 9.4 ТЗ — таблица "Ответы обоих" → "Результат".
 * Чистая функция, используется и в processCheckinResult, и в тестах.
 */
export function resolveCheckinResult(
  answerA: CheckinAnswer,
  answerB: CheckinAnswer
): CheckinResult {
  if (answerA === "yes" && answerB === "yes") return "success";
  if (answerA === "no" || answerB === "no") return "failed";
  return "partial";
}
