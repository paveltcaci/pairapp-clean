import { CallableRequest } from "firebase-functions/v2/https";
import { Errors } from "./errors";

/**
 * Достаёт uid из callable-запроса и кидает unauthenticated, если
 * пользователь не залогинен. Использовать в начале каждой onCall-функции.
 */
export function requireAuth<T>(request: CallableRequest<T>): string {
  const uid = request.auth?.uid;
  if (!uid) {
    throw Errors.unauthenticated();
  }
  return uid;
}

/**
 * Достаёт custom claim "role" (раздел 3 ТЗ — роль "Администратор").
 * Используется в admin-функциях панели управления.
 */
export function requireAdmin<T>(request: CallableRequest<T>): string {
  const uid = requireAuth(request);
  const role = request.auth?.token?.role;
  if (role !== "admin") {
    throw Errors.permissionDenied("Требуются права администратора.");
  }
  return uid;
}
