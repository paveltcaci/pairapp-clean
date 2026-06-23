import { onCall } from "firebase-functions/v2/https";
import { requireAuth } from "../../utils/auth";
import { getCoupleContext } from "../../utils/couple-context";
import { Errors } from "../../utils/errors";

/**
 * Встроенные факты, привязанные к вехам (раздел 10.3 ТЗ). Ключ — количество
 * дней или месяцев, milestoneUnit уточняет единицу. Тексты хранятся как
 * ключи локализации (i18n на клиенте), а не готовые строки — тот же
 * принцип, что и в push.ts: backend не должен решать, на каком языке
 * показывать текст пользователю.
 */
export interface RelationshipMilestoneFact {
  unit: "days" | "months" | "years";
  value: number;
  factKey: string;
}

export const BUILTIN_MILESTONE_FACTS: RelationshipMilestoneFact[] = [
  { unit: "days", value: 7, factKey: "fact.days7" },
  { unit: "days", value: 30, factKey: "fact.days30" },
  { unit: "days", value: 100, factKey: "fact.days100" },
  { unit: "days", value: 365, factKey: "fact.days365" },
  { unit: "days", value: 500, factKey: "fact.days500" },
  { unit: "days", value: 1000, factKey: "fact.days1000" },
  { unit: "months", value: 22, factKey: "fact.months22" },
  { unit: "years", value: 2, factKey: "fact.years2" },
  { unit: "years", value: 5, factKey: "fact.years5" },
];

interface CounterBreakdown {
  totalDays: number;
  years: number;
  months: number;
  days: number;
}

/** Чистая функция разбивки "N дней вместе" на годы/месяцы/дни — раздел 10.2 ТЗ. */
export function calculateRelationshipBreakdown(
  startDate: Date,
  now: Date
): CounterBreakdown {
  const totalDays = Math.floor(
    (now.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)
  );

  let years = now.getFullYear() - startDate.getFullYear();
  let months = now.getMonth() - startDate.getMonth();
  let days = now.getDate() - startDate.getDate();

  if (days < 0) {
    months -= 1;
    const prevMonth = new Date(now.getFullYear(), now.getMonth(), 0);
    days += prevMonth.getDate();
  }
  if (months < 0) {
    years -= 1;
    months += 12;
  }

  return { totalDays, years, months, days };
}

/** Следующая годовщина (раздел 10.2 ТЗ: "с обратным отсчётом"). */
export function nextAnniversary(startDate: Date, now: Date): { date: Date; daysUntil: number } {
  const next = new Date(startDate);
  next.setFullYear(now.getFullYear());
  if (next.getTime() < now.getTime()) {
    next.setFullYear(now.getFullYear() + 1);
  }
  const daysUntil = Math.ceil((next.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
  return { date: next, daysUntil };
}

/** Подбирает факт, если totalDays/months/years совпадает с одной из вех. */
export function findMilestoneFact(
  breakdown: CounterBreakdown
): RelationshipMilestoneFact | null {
  const totalMonths = breakdown.years * 12 + breakdown.months;
  return (
    BUILTIN_MILESTONE_FACTS.find(
      (f) =>
        (f.unit === "days" && f.value === breakdown.totalDays) ||
        (f.unit === "months" && f.value === totalMonths) ||
        (f.unit === "years" && f.value === breakdown.years)
    ) ?? null
  );
}

/**
 * getRelationshipCounter — не выделена отдельной строкой в разделе 18
 * (список Cloud Functions), но необходима как backend-источник истины
 * для экрана "Мы вместе" (раздел 10, раздел 19 — экран "Счётчик"),
 * чтобы оба партнёра видели одинаковые цифры независимо от часового
 * пояса устройства, и чтобы факты (раздел 10.3 ТЗ) были централизованы.
 */
export const getRelationshipCounter = onCall(async (request) => {
  const uid = requireAuth(request);
  const { couple } = await getCoupleContext(uid);

  if (!couple.relationshipStartDate) {
    throw Errors.failedPrecondition(
      "Дата начала отношений ещё не установлена."
    );
  }
  if (
    !couple.relationshipStartConfirmedByA ||
    !couple.relationshipStartConfirmedByB
  ) {
    return {
      confirmed: false,
      pendingDate: couple.relationshipStartDate.toDate().toISOString(),
    };
  }

  const startDate = couple.relationshipStartDate.toDate();
  const now = new Date();
  const breakdown = calculateRelationshipBreakdown(startDate, now);
  const anniversary = nextAnniversary(startDate, now);
  const fact = findMilestoneFact(breakdown);

  return {
    confirmed: true,
    totalDays: breakdown.totalDays,
    years: breakdown.years,
    months: breakdown.months,
    days: breakdown.days,
    nextAnniversaryDate: anniversary.date.toISOString(),
    daysUntilAnniversary: anniversary.daysUntil,
    factKey: fact?.factKey ?? null,
  };
});
