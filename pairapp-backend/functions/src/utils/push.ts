import { messaging, db, Collections } from "../config/firebase";
import {
  NotificationSettings,
  SupportedLanguage,
  UserDoc,
} from "../types";
import * as logger from "firebase-functions/logger";

export type NotificationType = keyof NotificationSettings;

export interface PushPayload {
  titleKey: string;
  bodyKey: string;
  params?: Record<string, string | number>;
  data?: Record<string, string>;
}

type PushTextDictionary = Record<
  string,
  Record<SupportedLanguage, string>
>;

const DEFAULT_LANGUAGE: SupportedLanguage = "ru";

const PUSH_TEXTS: PushTextDictionary = {
  "push.newIssue.title": {
    ru: "Новая проблема",
    en: "New issue",
  },
  "push.newIssue.body": {
    ru: "Партнёр добавил новую тему для обсуждения.",
    en: "Your partner added a new topic to discuss.",
  },

  "push.issueReply.title": {
    ru: "Новый ответ",
    en: "New reply",
  },
  "push.issueReply.body": {
    ru: "Партнёр ответил в обсуждении проблемы.",
    en: "Your partner replied in an issue discussion.",
  },

  "push.solutionProposed.title": {
    ru: "Предложено решение",
    en: "Solution proposed",
  },
  "push.solutionProposed.body": {
    ru: "Партнёр предложил вариант решения.",
    en: "Your partner proposed a solution.",
  },

  "push.issueReopened.title": {
    ru: "Проблема открыта снова",
    en: "Issue reopened",
  },
  "push.issueReopened.body": {
    ru: "Партнёр снова открыл обсуждение проблемы.",
    en: "Your partner reopened the issue discussion.",
  },

  "push.agreementProposed.title": {
    ru: "Новая договорённость",
    en: "New agreement",
  },
  "push.agreementProposed.body": {
    ru: "Партнёр предложил договорённость.",
    en: "Your partner proposed an agreement.",
  },

  "push.agreementAccepted.title": {
    ru: "Договорённость принята",
    en: "Agreement accepted",
  },
  "push.agreementAccepted.body": {
    ru: "Партнёр подтвердил договорённость.",
    en: "Your partner accepted the agreement.",
  },

  "push.agreementActive.title": {
    ru: "Договорённость активна",
    en: "Agreement is active",
  },
  "push.agreementActive.body": {
    ru: "Вы оба подтвердили договорённость.",
    en: "You both accepted the agreement.",
  },

  "push.checkinDue.title": {
    ru: "Пора проверить договорённость",
    en: "Agreement check-in",
  },
  "push.checkinDue.body": {
    ru: "Ответьте, работает ли ваша договорённость.",
    en: "Answer whether your agreement is working.",
  },

  "push.checkinAwaitingPartner.title": {
    ru: "Проверка договорённости",
    en: "Agreement check-in",
  },
  "push.checkinAwaitingPartner.body": {
    ru: "Партнёр уже ответил. Теперь ждём ваш ответ.",
    en: "Your partner has answered. Now it is your turn.",
  },

  "push.anniversary.title": {
    ru: "Ваша годовщина",
    en: "Your anniversary",
  },
  "push.anniversary.body": {
    ru: "Сегодня особенный день для вашей пары.",
    en: "Today is a special day for your couple.",
  },

  "push.relationshipDateProposed.title": {
    ru: "Дата отношений",
    en: "Relationship date",
  },
  "push.relationshipDateProposed.body": {
    ru: "Партнёр предложил дату начала отношений: {date}.",
    en: "Your partner proposed a relationship start date: {date}.",
  },

  "push.quizStarted.title": {
    ru: "Новый квиз",
    en: "New quiz",
  },
  "push.quizStarted.body": {
    ru: "Партнёр запустил квиз для вас двоих.",
    en: "Your partner started a quiz for both of you.",
  },

  "push.quizCompleted.title": {
    ru: "Квиз завершён",
    en: "Quiz completed",
  },
  "push.quizCompleted.body": {
    ru: "Ответы готовы. Посмотрите результат.",
    en: "Answers are ready. See the result.",
  },

  "push.activityIdeaAdded.title": {
    ru: "Новая идея",
    en: "New idea",
  },
  "push.activityIdeaAdded.body": {
    ru: "Партнёр добавил идею совместного занятия.",
    en: "Your partner added a new activity idea.",
  },

  "push.partnerLeft.title": {
    ru: "Партнёр вышел из пары",
    en: "Partner left the couple",
  },
  "push.partnerLeft.body": {
    ru: "Ваш партнёр покинул пару в приложении.",
    en: "Your partner left the couple in the app.",
  },

  "push.partnerJoined.title": {
    ru: "Партнёр подключился",
    en: "Partner joined",
  },
  "push.partnerJoined.body": {
    ru: "Партнёр подключился к вашей паре.",
    en: "Your partner joined your couple.",
  },
};

function normalizeLanguage(language: string | null | undefined): SupportedLanguage {
  return language === "en" ? "en" : DEFAULT_LANGUAGE;
}

function formatText(
  template: string,
  params?: Record<string, string | number>
): string {
  if (!params) return template;

  return template.replace(/\{(\w+)\}/g, (_, key: string) => {
    const value = params[key];
    return value === undefined ? `{${key}}` : String(value);
  });
}

export function resolvePushText(
  key: string,
  language: string | null | undefined,
  params?: Record<string, string | number>
): string {
  const lang = normalizeLanguage(language);
  const fallback = PUSH_TEXTS[key]?.[DEFAULT_LANGUAGE] ?? key;
  const template = PUSH_TEXTS[key]?.[lang] ?? fallback;

  return formatText(template, params);
}

/**
 * Отправляет push конкретному пользователю.
 *
 * Важно:
 * - если у пользователя нет FCM-токенов, функция тихо завершается;
 * - если тип уведомления выключен в настройках, push не отправляется;
 * - title/body отправляются уже локализованным текстом;
 * - titleKey/bodyKey остаются в data для будущей клиентской логики.
 */
export async function sendPushToUser(
  userId: string,
  type: NotificationType,
  payload: PushPayload
): Promise<void> {
  const userSnap = await db.collection(Collections.users).doc(userId).get();
  if (!userSnap.exists) return;

  const user = userSnap.data() as UserDoc;

  const notificationSettings =
    user.notificationSettings ?? ({} as Partial<NotificationSettings>);

  if (notificationSettings[type] === false) {
    logger.debug(`Push '${type}' skipped: disabled by user ${userId}`);
    return;
  }

  const tokens = user.fcmTokens ?? [];

  if (tokens.length === 0) {
    logger.debug(`Push '${type}' skipped: no FCM tokens for user ${userId}`);
    return;
  }

  const language = normalizeLanguage(user.language);

  const title = resolvePushText(payload.titleKey, language, payload.params);
  const body = resolvePushText(payload.bodyKey, language, payload.params);

  const message = {
    tokens,
    notification: {
      title,
      body,
    },
    data: {
      type,
      titleKey: payload.titleKey,
      bodyKey: payload.bodyKey,
      language,
      ...(payload.params ? { params: JSON.stringify(payload.params) } : {}),
      ...(payload.data ?? {}),
    },
  };

  const response = await messaging.sendEachForMulticast(message);

  const tokensToRemove: string[] = [];

  response.responses.forEach((res, idx) => {
    if (
      !res.success &&
      (res.error?.code === "messaging/registration-token-not-registered" ||
        res.error?.code === "messaging/invalid-registration-token")
    ) {
      tokensToRemove.push(tokens[idx]);
    }
  });

  if (tokensToRemove.length > 0) {
    await db
      .collection(Collections.users)
      .doc(userId)
      .update({
        fcmTokens: tokens.filter((token) => !tokensToRemove.includes(token)),
      });
  }
}

export async function sendPushToUsers(
  userIds: string[],
  type: NotificationType,
  payload: PushPayload
): Promise<void> {
  await Promise.all(userIds.map((id) => sendPushToUser(id, type, payload)));
}