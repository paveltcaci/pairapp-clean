import { onSchedule } from "firebase-functions/v2/scheduler";
import { db, Collections } from "../../config/firebase";
import { CoupleDoc } from "../../types";
import { sendPushToUsers } from "../../utils/push";
import * as logger from "firebase-functions/logger";

/**
 * notifyAnniversaries — раздел 14 ТЗ: "Годовщина отношений" → "Оба
 * партнёра". Не выделена отдельной строкой в разделе 18 (там перечислены
 * только бизнес-операции по запросу пользователя), но необходима как
 * единственный способ доставить push-событие, которое НЕ инициируется
 * действием пользователя — годовщина наступает по календарю, а не по
 * нажатию кнопки.
 *
 * Запускается раз в сутки и сравнивает день/месяц relationshipStartDate
 * с текущей датой (без учёта года — годовщина повторяется ежегодно).
 */
export const notifyAnniversaries = onSchedule(
  { schedule: "every day 09:00", timeZone: "UTC" },
  async () => {
    const today = new Date();
    const couplesSnap = await db
      .collection(Collections.couples)
      .where("status", "==", "active")
      .get();

    let notified = 0;

    for (const doc of couplesSnap.docs) {
      const couple = doc.data() as CoupleDoc;
      if (
        !couple.relationshipStartDate ||
        !couple.relationshipStartConfirmedByA ||
        !couple.relationshipStartConfirmedByB
      ) {
        continue;
      }

      const startDate = couple.relationshipStartDate.toDate();
      const isAnniversaryToday =
        startDate.getDate() === today.getDate() &&
        startDate.getMonth() === today.getMonth() &&
        // Раздел 10.3 ТЗ показывает факты уже с первого года, поэтому
        // не уведомляем в день старта отношений (0 полных лет) — только
        // начиная с первой годовщины.
        today.getFullYear() > startDate.getFullYear();

      if (!isAnniversaryToday) continue;

      const recipients = [couple.partnerAId, couple.partnerBId].filter(
        (id): id is string => !!id
      );
      await sendPushToUsers(recipients, "anniversary", {
        titleKey: "push.anniversary.title",
        bodyKey: "push.anniversary.body",
        data: { coupleId: doc.id },
      });
      notified++;
    }

    logger.info(`notifyAnniversaries: notified ${notified} couple(s).`);
  }
);
