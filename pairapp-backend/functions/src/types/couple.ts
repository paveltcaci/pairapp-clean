import { FieldValue } from "firebase-admin/firestore";
import { CoupleStatus, FirestoreTimestamp } from "./common";

/**
 * Коллекция `couples` (раздел 17.2 ТЗ).
 */
export interface CoupleDoc {
  id: string;
  partnerAId: string;
  partnerBId: string | null;
  relationshipStartDate: FirestoreTimestamp | null;
  relationshipStartConfirmedByA: boolean;
  relationshipStartConfirmedByB: boolean;
  /** Бессрочный код, см. раздел 6.2 ТЗ. Уникален среди active-кодов. */
  inviteCode: string;
  inviteCodeUsed: boolean;
  status: CoupleStatus;
  createdAt: FirestoreTimestamp;
  updatedAt: FirestoreTimestamp | FieldValue;
  disconnectedAt: FirestoreTimestamp | null;
  settings: CoupleSettings;
}

/** Раздел 6.4 ТЗ: "settings: Map — Приватность и прочие настройки пары." */
export interface CoupleSettings {
  /** Зарезервировано под будущую приватность пары (например, скрытие квизов от уведомлений и т.п.). */
  [key: string]: unknown;
}

export const DEFAULT_COUPLE_SETTINGS: CoupleSettings = {};

/**
 * Вспомогательный тип для резолва "кто из партнёров — A, кто — B"
 * относительно конкретного userId. Используется почти во всех модулях.
 */
export interface PartnerResolution {
  selfSlot: "A" | "B";
  partnerSlot: "A" | "B";
  selfId: string;
  partnerId: string | null;
}
