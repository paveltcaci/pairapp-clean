import { db, Collections } from "../config/firebase";

/** Символы без визуально похожих друг на друга (0/O, 1/I и т.п.) — раздел 6.2 ТЗ. */
const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
const CODE_LENGTH = 8;
const MAX_GENERATION_ATTEMPTS = 10;

function randomCode(): string {
  let code = "";
  for (let i = 0; i < CODE_LENGTH; i++) {
    code += CODE_ALPHABET[Math.floor(Math.random() * CODE_ALPHABET.length)];
  }
  return code;
}

/**
 * Генерирует invite-код, уникальный среди ещё не использованных кодов
 * (раздел 6.2 ТЗ: код бессрочный, одноразовый). Использованные коды можно
 * не проверять на уникальность — они уже неактивны, но проверяем по всем
 * для простоты и предсказуемости.
 */
export async function generateUniqueInviteCode(): Promise<string> {
  for (let attempt = 0; attempt < MAX_GENERATION_ATTEMPTS; attempt++) {
    const code = randomCode();
    const existing = await db
      .collection(Collections.couples)
      .where("inviteCode", "==", code)
      .limit(1)
      .get();
    if (existing.empty) {
      return code;
    }
  }
  throw new Error(
    "Не удалось сгенерировать уникальный invite-код за разумное число попыток."
  );
}
