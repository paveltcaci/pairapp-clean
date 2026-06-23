import { onCall } from "firebase-functions/v2/https";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { z } from "zod";
import { db, Collections, auth } from "../../config/firebase";
import { requireAdmin } from "../../utils/auth";
import { parseOrThrow } from "../../utils/validation";
import { Errors } from "../../utils/errors";
import { ReportDoc } from "../../types";
import { writeAuditLog } from "../../utils/audit-log";

/**
 * Раздел 23.2 ТЗ — "Действия по жалобе": закрыть без действия, скрыть/
 * удалить контент, заблокировать пользователя, разблокировать
 * пользователя. Реализованы как набор административных callable-функций,
 * защищённых custom claim `role: 'admin'` (см. utils/auth.ts).
 *
 * Назначение роли админа — отдельная ручная операция (через Firebase
 * Console или setAdminRole, см. ниже), не описанная в разделе 17/18 ТЗ
 * как пользовательский сценарий, потому что админы не проходят обычную
 * регистрацию (раздел 3 ТЗ: "Администратор — Внутренняя роль").
 */

const reviewReportSchema = z.object({
  reportId: z.string().min(1),
  action: z.enum(["dismiss", "hide_content", "block_user", "unblock_user"]),
  adminNote: z.string().trim().max(2000).nullish(),
});

export const reviewReport = onCall(async (request) => {
  const adminUid = requireAdmin(request);
  const input = parseOrThrow(reviewReportSchema, request.data);

  const reportRef = db.collection(Collections.reports).doc(input.reportId);
  const reportSnap = await reportRef.get();
  if (!reportSnap.exists) {
    throw Errors.notFound("Жалоба");
  }
  const report = reportSnap.data() as ReportDoc;

  const statusByAction: Record<string, ReportDoc["status"]> = {
    dismiss: "dismissed",
    hide_content: "resolved",
    block_user: "resolved",
    unblock_user: "resolved",
  };

  await reportRef.update({
    status: statusByAction[input.action],
    reviewedAt: Timestamp.now(),
    reviewedBy: adminUid,
    adminNote: input.adminNote ?? null,
  });

  if (input.action === "hide_content") {
    if (report.targetType === "message") {
      await db.collection(Collections.issueMessages).doc(report.targetId).update({
        isDeleted: true,
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else if (report.targetType === "issue") {
      await db.collection(Collections.issues).doc(report.targetId).update({
        status: "archived",
        archivedAt: Timestamp.now(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  }

  if (input.action === "block_user") {
    await db.collection(Collections.users).doc(report.reportedUserId).update({
      isBlocked: true,
      updatedAt: FieldValue.serverTimestamp(),
    });
    await writeAuditLog({
      action: "user_blocked_by_admin",
      actorId: adminUid,
      targetUserId: report.reportedUserId,
      metadata: { reportId: input.reportId },
    });
  }

  if (input.action === "unblock_user") {
    await db.collection(Collections.users).doc(report.reportedUserId).update({
      isBlocked: false,
      updatedAt: FieldValue.serverTimestamp(),
    });
    await writeAuditLog({
      action: "user_unblocked_by_admin",
      actorId: adminUid,
      targetUserId: report.reportedUserId,
      metadata: { reportId: input.reportId },
    });
  }

  await writeAuditLog({
    action: "report_reviewed",
    actorId: adminUid,
    targetUserId: report.reportedUserId,
    targetCoupleId: report.coupleId,
    metadata: { reportId: input.reportId, action: input.action },
  });

  return { success: true };
});

/**
 * setAdminUserBlocked — раздел 23.1 ТЗ: "Пользователи — поиск, просмотр,
 * блокировка/разблокировка" в общем разделе панели, независимо от
 * конкретной жалобы (в отличие от reviewReport, который привязан к
 * record'у жалобы).
 */
const setAdminUserBlockedSchema = z.object({
  userId: z.string().min(1),
  isBlocked: z.boolean(),
});

export const setAdminUserBlocked = onCall(async (request) => {
  requireAdmin(request);
  const input = parseOrThrow(setAdminUserBlockedSchema, request.data);

  await db.collection(Collections.users).doc(input.userId).update({
    isBlocked: input.isBlocked,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { success: true };
});

/**
 * setAdminRole — назначение/снятие custom claim 'admin'. Сама эта функция
 * защищена requireAdmin, поэтому первый администратор должен быть
 * назначен вручную через Firebase Admin SDK (одноразовый bootstrap-
 * скрипт, см. scripts/bootstrap-admin.ts) — иначе создаётся
 * курица-и-яйцо проблема для самой первой учётной записи.
 */
const setAdminRoleSchema = z.object({
  userId: z.string().min(1),
  isAdmin: z.boolean(),
});

export const setAdminRole = onCall(async (request) => {
  requireAdmin(request);
  const input = parseOrThrow(setAdminRoleSchema, request.data);

  await auth.setCustomUserClaims(input.userId, {
    role: input.isAdmin ? "admin" : "user",
  });

  return { success: true };
});
