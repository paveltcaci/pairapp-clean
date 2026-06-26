import { onCall } from "firebase-functions/v2/https";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, submitCheckinAnswerSchema } from "../../utils/validation";
import { getActiveCoupleOrThrow, resolvePartner } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";
import { sendPushToUser } from "../../utils/push";
import {
  AgreementDoc,
  CheckinDoc,
  IssueMessageDoc,
  SubmitCheckinAnswerInput,
  resolveCheckinResult,
} from "../../types";

/**
 * submitCheckinAnswer (раздел 9.4, 18 ТЗ) — "Отправка ответа на check-in".
 *
 * processCheckinResult (раздел 9.4, 18 ТЗ) — "Вычисление результата после
 * ответов обоих" — реализована не как отдельная вызываемая функция, а как
 * внутренний шаг этой же транзакции: как только оба ответа присутствуют,
 * результат вычисляется немедленно. Разделение на два отдельных вызова
 * добавило бы задержку и риск рассинхронизации без какой-либо пользы —
 * результат детерминирован по таблице раздела 9.4 и не требует отдельного
 * пользовательского действия для "запуска" вычисления.
 */
export const submitCheckinAnswer = onCall<SubmitCheckinAnswerInput>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(submitCheckinAnswerSchema, request.data);
    const { couple } = await getActiveCoupleOrThrow(uid);
    const { selfSlot, partnerId } = resolvePartner(couple, uid);

    const checkinRef = db.collection(Collections.checkins).doc(input.checkinId);

    const outcome = await db.runTransaction(async (tx) => {
      const checkinSnap = await tx.get(checkinRef);
      if (!checkinSnap.exists) {
        throw Errors.notFound("Запись проверки (check-in)");
      }
      const checkin = checkinSnap.data() as CheckinDoc;

      if (checkin.coupleId !== couple.id) {
        throw Errors.permissionDenied("Этот check-in принадлежит другой паре.");
      }
      if (checkin.status === "completed") {
        throw Errors.failedPrecondition("Этот check-in уже завершён.");
      }

      const now = Timestamp.now();
      const patch: Record<string, unknown> = {};

      if (selfSlot === "A") {
        if (checkin.partnerAAnswer) {
          throw Errors.failedPrecondition("Вы уже ответили на эту проверку.");
        }
        patch.partnerAAnswer = input.answer;
        patch.partnerAAnsweredAt = now;
      } else {
        if (checkin.partnerBAnswer) {
          throw Errors.failedPrecondition("Вы уже ответили на эту проверку.");
        }
        patch.partnerBAnswer = input.answer;
        patch.partnerBAnsweredAt = now;
      }

      const answerA = selfSlot === "A" ? input.answer : checkin.partnerAAnswer;
      const answerB = selfSlot === "B" ? input.answer : checkin.partnerBAnswer;
      const bothAnswered = !!answerA && !!answerB;

      if (!bothAnswered) {
        patch.status = "partial";
        tx.update(checkinRef, patch);
        return { bothAnswered: false, result: null };
      }

      // --- processCheckinResult: оба ответили, применяем таблицу раздела 9.4 ---
      const result = resolveCheckinResult(answerA!, answerB!);
      patch.status = "completed";
      patch.result = result;
      patch.completedAt = now;

      const agreementRef = db.collection(Collections.agreements).doc(checkin.agreementId);
      let agreement: AgreementDoc | null = null;
      let hasOtherPendingCheckin = false;

      if (result === "partial") {
        const agreementSnap = await tx.get(agreementRef);
        if (!agreementSnap.exists) {
          throw Errors.notFound("Agreement");
        }
        agreement = agreementSnap.data() as AgreementDoc;

        const pendingCheckinsSnap = await tx.get(
          db
            .collection(Collections.checkins)
            .where("agreementId", "==", checkin.agreementId)
            .where("status", "==", "pending")
        );
        hasOtherPendingCheckin = pendingCheckinsSnap.docs.some(
          (doc) => doc.id !== input.checkinId
        );
      }

      tx.update(checkinRef, patch);

      let issueRef: FirebaseFirestore.DocumentReference | null = null;
      if (checkin.issueId) {
        issueRef = db.collection(Collections.issues).doc(checkin.issueId);
      }

      if (result === "success") {
        // "Оба «Да» → Проблема → solved, договорённость → completed (или active)"
        // (раздел 9.4 ТЗ). Договорённость без точной даты "окончания" по
        // смыслу одноразовая → completed; постоянные правила (например,
        // регулярные обязанности) лучше переоценивать через новый checkin,
        // но MVP не вводит recurring-договорённости (раздел 9 ТЗ их не
        // описывает), поэтому всегда переводим в completed.
        if (agreementRef) {
          tx.update(agreementRef, {
            status: "completed",
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
        if (issueRef) {
          tx.update(issueRef, {
            status: "solved",
            solvedAt: now,
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
      } else if (result === "partial") {
        // "Один «Частично» → Проблема остаётся agreed, создаётся
        // checkin-сообщение, предлагается обсудить корректировку"
        // (раздел 9.4 ТЗ). Статус проблемы не трогаем.
        if (issueRef && checkin.issueId) {
          const messageRef = db.collection(Collections.issueMessages).doc();
          const messageDoc: IssueMessageDoc = {
            id: messageRef.id,
            issueId: checkin.issueId,
            coupleId: couple.id,
            authorId: uid,
            type: "checkin",
            text: "checkin.partial", // ключ локализации, не готовый текст
            createdAt: now,
            updatedAt: null,
            isDeleted: false,
            readByPartner: false,
          };
          tx.set(messageRef, messageDoc);
        }

        if (agreement && !hasOtherPendingCheckin) {
          const intervalDays =
            typeof agreement.checkIntervalDays === "number" &&
            agreement.checkIntervalDays > 0
              ? agreement.checkIntervalDays
              : 7;
          const nextScheduledAt = Timestamp.fromMillis(
            now.toMillis() + intervalDays * 24 * 60 * 60 * 1000
          );
          const nextCheckinRef = db.collection(Collections.checkins).doc();
          const nextCheckinDoc: CheckinDoc = {
            id: nextCheckinRef.id,
            agreementId: checkin.agreementId,
            issueId: checkin.issueId ?? null,
            coupleId: checkin.coupleId,
            scheduledAt: nextScheduledAt,
            partnerAAnswer: null,
            partnerBAnswer: null,
            partnerAAnsweredAt: null,
            partnerBAnsweredAt: null,
            status: "pending",
            result: null,
            createdAt: now,
            completedAt: null,
            notifiedAt: null,
          };
          tx.set(nextCheckinRef, nextCheckinDoc);
        }
      } else {
        // "Один «Нет» → Проблема → reopened, создаётся системное сообщение"
        // (раздел 9.4 ТЗ).
        if (agreementRef) {
          tx.update(agreementRef, {
            status: "failed",
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
        if (issueRef && checkin.issueId) {
          tx.update(issueRef, {
            status: "reopened",
            reopenedAt: now,
            updatedAt: FieldValue.serverTimestamp(),
          });
          const messageRef = db.collection(Collections.issueMessages).doc();
          const messageDoc: IssueMessageDoc = {
            id: messageRef.id,
            issueId: checkin.issueId,
            coupleId: couple.id,
            authorId: uid,
            type: "checkin",
            text: "checkin.failed",
            createdAt: now,
            updatedAt: null,
            isDeleted: false,
            readByPartner: false,
          };
          tx.set(messageRef, messageDoc);
        }
      }

      return { bothAnswered: true, result };
    });

    if (partnerId) {
      if (!outcome.bothAnswered) {
        // Информируем партнёра, что его ответ ещё ожидается — переиспользуем
        // тип checkinDue, т.к. отдельного типа в разделе 14 ТЗ для этого нет.
        await sendPushToUser(partnerId, "checkinDue", {
          titleKey: "push.checkinAwaitingPartner.title",
          bodyKey: "push.checkinAwaitingPartner.body",
          data: { checkinId: input.checkinId },
        });
      }
    }

    return outcome;
  }
);
