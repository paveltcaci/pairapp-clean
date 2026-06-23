import { HttpsError } from "firebase-functions/v2/https";

/**
 * Тонкие обёртки над HttpsError, чтобы все модули бросали ошибки
 * единообразно и с предсказуемыми кодами для клиента (Flutter).
 */
export const Errors = {
  unauthenticated: (msg = "Требуется авторизация.") =>
    new HttpsError("unauthenticated", msg),

  notFound: (resource: string) =>
    new HttpsError("not-found", `${resource} не найден(а).`),

  permissionDenied: (msg = "Недостаточно прав для этого действия.") =>
    new HttpsError("permission-denied", msg),

  invalidArgument: (msg: string) => new HttpsError("invalid-argument", msg),

  failedPrecondition: (msg: string) =>
    new HttpsError("failed-precondition", msg),

  alreadyExists: (msg: string) => new HttpsError("already-exists", msg),

  internal: (msg = "Внутренняя ошибка сервера.") =>
    new HttpsError("internal", msg),

  resourceExhausted: (msg: string) =>
    new HttpsError("resource-exhausted", msg),
};
