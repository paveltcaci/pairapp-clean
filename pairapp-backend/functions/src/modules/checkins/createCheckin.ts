import { onSchedule } from "firebase-functions/v2/scheduler";
import { Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { CheckinDoc, CoupleDoc } from "../../types";
import { sendPushToUser } from "../../utils/push";
import * as logger from "firebase-functions/logger";

/**
 * createCheckin (раздел 9.4, 18 ТЗ): "В день проверки оба партнёра
 * получают push-уведомление."
 *
 * В этой системе Checkin-документ для активной договорённости создаётся
 * заранее, в момент acceptAgreement (см. модуль agreements) — так
 * checkDate известен сразу и не нужно гадать. Поэтому роль этой
 * scheduled-функции — не "создать" checkin (он уже существует в статусе
 * pending), а обнаружить, что наступила его scheduledAt дата, и отправить
 * push обоим партнёрам. Название createCheckin сохранено как в разделе 18
 * ТЗ для прямой трассируемости, хотя по факту функция "активирует"
 * уведомление, а не создаёт документ.
 *
 * Повторных push на одну и ту же дату избегаем флагом notifiedAt —
 * проверяем его перед отправкой и выставляем после.
 */
export const createCheckin = onSchedule(
  { schedule: "every 60 minutes", timeZone: "UTC" },
  async () => {
    const now = Timestamp.now();

    const duePending = await db
      .collection(Collections.checkins)
      .where("status", "==", "pending")
      .where("scheduledAt", "<=", now)
      .get();

    if (duePending.empty) {
      logger.info("createCheckin: no due checkins.");
      return;
    }

    for (const doc of duePending.docs) {
      const checkin = doc.data() as CheckinDoc;
      if (checkin.notifiedAt) continue; // уже уведомили в прошлом запуске

      const coupleSnap = await db
        .collection(Collections.couples)
        .doc(checkin.coupleId)
        .get();
      if (!coupleSnap.exists) continue;
      const couple = coupleSnap.data() as CoupleDoc;

      const recipients = [couple.partnerAId, couple.partnerBId].filter(
        (id): id is string => !!id
      );

      await Promise.all(
        recipients.map((userId) =>
          sendPushToUser(userId, "checkinDue", {
            titleKey: "push.checkinDue.title",
            bodyKey: "push.checkinDue.body",
            data: { checkinId: doc.id, agreementId: checkin.agreementId },
          })
        )
      );

      await doc.ref.update({ notifiedAt: now });
    }

    logger.info(`createCheckin: notified for ${duePending.size} checkin(s).`);
  }
);
