import { onCall } from "firebase-functions/v2/https";
import { Timestamp, FieldValue } from "firebase-admin/firestore";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, registerUserSchema } from "../../utils/validation";
import { Errors } from "../../utils/errors";
import { RegisterUserInput } from "../../types";

const MIN_AGE_YEARS = 16; // Раздел 5.3 ТЗ.

function calculateAge(birthDate: Date, now: Date): number {
  let age = now.getFullYear() - birthDate.getFullYear();
  const monthDiff = now.getMonth() - birthDate.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && now.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
}

/**
 * completeUserProfile — дозаполняет анкету сразу после регистрации
 * (раздел 5.2 ТЗ: имя, пол, дата рождения, язык, согласия). Не указана
 * отдельной строкой в разделе 18, но необходима, так как createUserProfile
 * (auth-триггер) не имеет доступа к этим полям формы.
 *
 * Также выполняет проверку возраста 16+ (раздел 5.3 ТЗ) — без этого
 * вызова дальнейшее использование приложения не имеет смысла, поэтому
 * сервер, а не только клиент, обязан перепроверить возраст.
 */
export const completeUserProfile = onCall<RegisterUserInput>(
  async (request) => {
    const uid = requireAuth(request);
    const input = parseOrThrow(registerUserSchema, request.data);

    const birthDate = new Date(input.birthDate);
    const age = calculateAge(birthDate, new Date());
    if (age < MIN_AGE_YEARS) {
      throw Errors.permissionDenied(
        `Приложение доступно пользователям от ${MIN_AGE_YEARS} лет.`
      );
    }

    const userRef = db.collection(Collections.users).doc(uid);
    const snap = await userRef.get();
    if (!snap.exists) {
      throw Errors.notFound("Профиль пользователя");
    }

    const now = FieldValue.serverTimestamp();
    await userRef.update({
      displayName: input.displayName,
      gender: input.gender,
      birthDate: Timestamp.fromDate(birthDate),
      language: input.language,
      acceptedTermsOfUseAt: now,
      acceptedPrivacyPolicyAt: now,
      updatedAt: now,
    });

    return { success: true };
  }
);
