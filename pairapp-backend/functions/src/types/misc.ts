import {
  FirestoreTimestamp,
  RelationshipEventType,
  ReportReason,
  ReportStatus,
  ReportTargetType,
  SubscriptionPlatform,
  SubscriptionStatus,
} from "./common";

/**
 * Коллекция `relationship_events` (раздел 17.13 ТЗ).
 */
export interface RelationshipEventDoc {
  id: string;
  coupleId: string;
  type: RelationshipEventType;
  title: string;
  description: string | null;
  date: FirestoreTimestamp;
  isRecurring: boolean;
  createdBy: string;
  createdAt: FirestoreTimestamp;
}

/**
 * Коллекция `reports` (раздел 17.14 ТЗ).
 */
export interface ReportDoc {
  id: string;
  reporterId: string;
  reportedUserId: string;
  coupleId: string;
  targetType: ReportTargetType;
  targetId: string;
  reason: ReportReason;
  comment: string | null;
  status: ReportStatus;
  createdAt: FirestoreTimestamp;
  reviewedAt: FirestoreTimestamp | null;
  reviewedBy: string | null;
  adminNote: string | null;
}

export interface CreateReportInput {
  targetType: ReportTargetType;
  targetId: string;
  reason: ReportReason;
  comment?: string | null;
}

export interface BlockUserInput {
  /** Жалоба, инициировавшая блокировку, опционально (раздел 16.2 ТЗ). */
  reportId?: string | null;
}

/**
 * Коллекция `subscriptions` (раздел 17.15 ТЗ).
 * Подписка покупается на пару, не на отдельного пользователя (раздел 20.2 ТЗ).
 */
export interface SubscriptionDoc {
  id: string;
  coupleId: string;
  purchasedByUserId: string;
  platform: SubscriptionPlatform;
  productId: string;
  status: SubscriptionStatus;
  startedAt: FirestoreTimestamp;
  expiresAt: FirestoreTimestamp;
  autoRenew: boolean;
  updatedAt: FirestoreTimestamp;
}
