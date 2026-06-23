import { auth as authTrigger } from "firebase-functions/v1";
import { db, Collections } from "../../config/firebase";
import { DEFAULT_NOTIFICATION_SETTINGS, UserDoc } from "../../types";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

/**
 * createUserProfile (раздел 18 ТЗ): "Создание профиля после регистрации".
 *
 * Реализован как auth.user().onCreate триггер (v1 API — для Auth-триггеров
 * это всё ещё рекомендуемый Firebase путь), а не как onCall, потому что
 * профиль должен создаваться синхронно с появлением записи в Firebase Auth,
 * независимо от того, через какой провайдер пользователь зарегистрировался
 * (email/password, Google, Apple — раздел 5.1 ТЗ).
 *
 * Базовый документ создаётся с минимальными дефолтами. Анкетные поля
 * (displayName, gender, birthDate, language, согласия) дозаполняются
 * клиентом сразу после регистрации через `completeUserProfile` —
 * это разделение нужно, т.к. onCreate-триггер не имеет доступа к
 * дополнительным полям формы регистрации, которые не входят в сам
 * Firebase Auth user record.
 */
export const createUserProfile = authTrigger.user().onCreate(async (user) => {
  const userRef = db.collection(Collections.users).doc(user.uid);

  const existing = await userRef.get();
  if (existing.exists) {
    logger.info(`User profile for ${user.uid} already exists, skipping.`);
    return;
  }

  const now = Timestamp.now();

  const doc: Partial<UserDoc> = {
    id: user.uid,
    email: user.email ?? "",
    displayName: user.displayName ?? "",
    avatarUrl: user.photoURL ?? null,
    // Плейсхолдер до заполнения формы — реальная дата приходит из
    // completeUserProfile и проверяется на возраст 16+ (раздел 5.3 ТЗ).
    birthDate: now,
    gender: "prefer_not_to_say",
    language: "ru",
    currentCoupleId: null,
    fcmTokens: [],
    notificationSettings: DEFAULT_NOTIFICATION_SETTINGS,
    createdAt: now,
    updatedAt: FieldValue.serverTimestamp(),
    lastLoginAt: now,
    isDeleted: false,
    isBlocked: false,
    acceptedTermsOfUseAt: null,
    acceptedPrivacyPolicyAt: null,
  };

  await userRef.set(doc);
  logger.info(`Created user profile for ${user.uid}`);
});
