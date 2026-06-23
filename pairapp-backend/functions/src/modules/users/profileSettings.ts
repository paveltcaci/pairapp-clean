import { onCall } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { z } from "zod";
import { db, Collections } from "../../config/firebase";
import { requireAuth } from "../../utils/auth";
import { parseOrThrow, updateFcmTokenSchema, removeFcmTokenSchema } from "../../utils/validation";
import { SUPPORTED_LANGUAGES } from "../../types/common";
import { Errors } from "../../utils/errors";

/**
 * updateProfile — смена имени/аватара (раздел 15.2 ТЗ: "Сменить имя / аватар").
 * Аватар загружается клиентом в Firebase Storage отдельно; здесь только
 * сохраняется итоговый URL.
 */
const updateProfileSchema = z.object({
  displayName: z.string().trim().min(1).max(60).optional(),
  avatarUrl: z.string().url().nullish(),
});

export const updateProfile = onCall(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(updateProfileSchema, request.data);

  if (input.displayName === undefined && input.avatarUrl === undefined) {
    throw Errors.invalidArgument("Нет данных для обновления.");
  }

  const patch: Record<string, unknown> = { updatedAt: FieldValue.serverTimestamp() };
  if (input.displayName !== undefined) patch.displayName = input.displayName;
  if (input.avatarUrl !== undefined) patch.avatarUrl = input.avatarUrl;

  await db.collection(Collections.users).doc(uid).update(patch);
  return { success: true };
});

/**
 * updateLanguage — раздел 4.4 ТЗ: "Язык выбирается при регистрации и
 * меняется в настройках профиля". Влияет только на текущего пользователя
 * (раздел 4.4: "Язык партнёра не влияет на язык текущего пользователя").
 */
const updateLanguageSchema = z.object({
  language: z.enum(SUPPORTED_LANGUAGES),
});

export const updateLanguage = onCall(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(updateLanguageSchema, request.data);

  await db.collection(Collections.users).doc(uid).update({
    language: input.language,
    updatedAt: FieldValue.serverTimestamp(),
  });
  return { success: true };
});

/**
 * updateNotificationSettings — раздел 15.2 ТЗ: "Управление уведомлениями".
 * Принимает частичный патч — выключают/включают по одному типу за раз
 * либо несколько сразу.
 */
const notificationSettingsPatchSchema = z
  .object({
    newIssue: z.boolean().optional(),
    issueReply: z.boolean().optional(),
    solutionProposed: z.boolean().optional(),
    agreementAccepted: z.boolean().optional(),
    checkinDue: z.boolean().optional(),
    anniversary: z.boolean().optional(),
    quizStarted: z.boolean().optional(),
    quizCompleted: z.boolean().optional(),
    activityIdeaAdded: z.boolean().optional(),
    partnerLeft: z.boolean().optional(),
    partnerJoined: z.boolean().optional(),
  })
  .refine((v) => Object.keys(v).length > 0, {
    message: "Нет данных для обновления.",
  });

export const updateNotificationSettings = onCall(async (request) => {
  const uid = requireAuth(request);
  const patch = parseOrThrow(notificationSettingsPatchSchema, request.data);

  const updatePayload: Record<string, unknown> = {
    updatedAt: FieldValue.serverTimestamp(),
  };
  for (const [key, value] of Object.entries(patch)) {
    updatePayload[`notificationSettings.${key}`] = value;
  }

  await db.collection(Collections.users).doc(uid).update(updatePayload);
  return { success: true };
});

/** registerFcmToken — добавляет токен текущего устройства (мульти-девайс). */
export const registerFcmToken = onCall(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(updateFcmTokenSchema, request.data);

  await db.collection(Collections.users).doc(uid).update({
    fcmTokens: FieldValue.arrayUnion(input.fcmToken),
    updatedAt: FieldValue.serverTimestamp(),
  });
  return { success: true };
});

/** unregisterFcmToken — вызывается при выходе/деавторизации устройства. */
export const unregisterFcmToken = onCall(async (request) => {
  const uid = requireAuth(request);
  const input = parseOrThrow(removeFcmTokenSchema, request.data);

  await db.collection(Collections.users).doc(uid).update({
    fcmTokens: FieldValue.arrayRemove(input.fcmToken),
    updatedAt: FieldValue.serverTimestamp(),
  });
  return { success: true };
});
