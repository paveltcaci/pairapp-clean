import { onCall } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, blockUserSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { BlockUserInput, ReportDoc } from "../../types";
import { writeAuditLog } from "../../utils/audit-log";

/**
 * blockUser (раздел 16.2, 18 ТЗ): "После блокировки партнёр теряет
 * возможность отправлять сообщения. Пара переходит в статус blocked.
 * Пользователь может удалить аккаунт или выйти из пары."
 *
 * Блокировка — это действие над ПАРОЙ (couple.status = 'blocked'),
 * а не флаг на отдельном пользователе: раздел 16.2 ТЗ описывает эффект
 * как "партнёр теряет возможность отправлять сообщения" внутри этой
 * связи, а раздел 17.1 ТЗ отдельно держит users.isBlocked для случая
 * административной блокировки нарушителя (раздел 23.2 ТЗ — действие
 * админа "Заблокировать пользователя"). Это два разных механизма:
 * - couple.status = 'blocked' — пользовательская блокировка партнёра;
 * - users.isBlocked = true — административная блокировка профиля.
 * Здесь реализуется первый механизм.
 */
export const blockUser = onCall<BlockUserInput>(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(blockUserSchema, request.data);
  const { couple, coupleRef } = await getActiveCoupleOrThrow(uid);
  resolvePartner(couple, uid);

  if (input.reportId) {
    const reportSnap = await db.collection(Collections.reports).doc(input.reportId).get();
    if (!reportSnap.exists) {
      throw Errors.notFound("Жалоба");
    }
    const report = reportSnap.data() as ReportDoc;
    if (report.coupleId !== couple.id || report.reporterId !== uid) {
      throw Errors.permissionDenied("Эта жалоба не принадлежит вам.");
    }
  }

  await coupleRef.update({
    status: "blocked",
    updatedAt: FieldValue.serverTimestamp(),
  });

  await writeAuditLog({
    action: "couple_blocked_by_user",
    actorId: uid,
    targetCoupleId: couple.id,
    metadata: { reportId: input.reportId ?? null },
  });

  return { success: true };
});
