import { Timestamp } from "firebase-admin/firestore";
import { db } from "../config/firebase";

/**
 * Раздел 21 ТЗ: "Логирование критических действий (удаление аккаунта,
 * блокировка)". Cloud Functions logger (firebase-functions/logger) пишет
 * в Cloud Logging, но это неудобно для административной панели (раздел
 * 23 ТЗ), которой нужен запрашиваемый, постоянный журнал внутри
 * Firestore. Поэтому критические действия дополнительно дублируются в
 * коллекцию `audit_logs` — не описанную явно в разделе 17 ТЗ (схема
 * фокусируется на пользовательских данных), но необходимую для
 * выполнения требования раздела 21 буквально ("логирование").
 */
export type AuditAction =
  | "account_deleted"
  | "user_blocked_by_admin"
  | "user_unblocked_by_admin"
  | "couple_blocked_by_user"
  | "report_reviewed";

export interface AuditLogEntry {
  action: AuditAction;
  actorId: string;
  targetUserId?: string | null;
  targetCoupleId?: string | null;
  metadata?: Record<string, unknown>;
  createdAt: Timestamp;
}

export async function writeAuditLog(
  entry: Omit<AuditLogEntry, "createdAt">
): Promise<void> {
  await db.collection("audit_logs").add({
    ...entry,
    createdAt: Timestamp.now(),
  });
}
