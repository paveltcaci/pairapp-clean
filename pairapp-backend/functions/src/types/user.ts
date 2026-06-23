import { FieldValue } from "firebase-admin/firestore";
import { FirestoreTimestamp, Gender, SupportedLanguage } from "./common";

/**
 * Коллекция `users` (раздел 17.1 ТЗ).
 * Document id === Firebase Auth UID.
 */
export interface UserDoc {
  id: string;
  email: string;
  displayName: string;
  avatarUrl: string | null;
  birthDate: FirestoreTimestamp;
  gender: Gender;
  language: SupportedLanguage;
  currentCoupleId: string | null;
  fcmTokens: string[];
  /** Настройки push-уведомлений по типам события (раздел 14 ТЗ). */
  notificationSettings: NotificationSettings;
  createdAt: FirestoreTimestamp;
  updatedAt: FirestoreTimestamp | FieldValue;
  lastLoginAt: FirestoreTimestamp;
  isDeleted: boolean;
  isBlocked: boolean;
  /**
   * Не предусмотрено явно схемой раздела 17.1, но юридически необходимо
   * хранить факт и момент согласия с Terms of Use / Privacy Policy
   * (раздел 5.2 ТЗ требует оба согласия как обязательные при регистрации).
   */
  acceptedTermsOfUseAt: FirestoreTimestamp | null;
  acceptedPrivacyPolicyAt: FirestoreTimestamp | null;
}

/**
 * Раздел 14 ТЗ: "Каждый тип уведомлений можно включить или выключить
 * в настройках профиля." Ключи соответствуют событиям из таблицы раздела 14.
 */
export interface NotificationSettings {
  newIssue: boolean;
  issueReply: boolean;
  solutionProposed: boolean;
  agreementAccepted: boolean;
  checkinDue: boolean;
  anniversary: boolean;
  quizStarted: boolean;
  quizCompleted: boolean;
  activityIdeaAdded: boolean;
  partnerLeft: boolean;
  /**
   * Не указано отдельной строкой в таблице раздела 14 ТЗ, но логически
   * необходимо: первый партнёр должен узнать, что второй подключился по
   * инвайт-коду (раздел 6.1 ТЗ, экран "Успешное подключение").
   */
  partnerJoined: boolean;
}

export const DEFAULT_NOTIFICATION_SETTINGS: NotificationSettings = {
  newIssue: true,
  issueReply: true,
  solutionProposed: true,
  agreementAccepted: true,
  checkinDue: true,
  anniversary: true,
  quizStarted: true,
  quizCompleted: true,
  activityIdeaAdded: true,
  partnerLeft: true,
  partnerJoined: true,
};

/** Payload, ожидаемый при регистрации (раздел 5.2 ТЗ). */
export interface RegisterUserInput {
  displayName: string;
  gender: Gender;
  /** ISO-8601 date string, например "1998-05-12". */
  birthDate: string;
  language: SupportedLanguage;
  acceptedTermsOfUse: boolean;
  acceptedPrivacyPolicy: boolean;
}
