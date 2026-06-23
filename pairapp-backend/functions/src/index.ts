/**
 * Точка входа Cloud Functions. Firebase Functions SDK обнаруживает
 * экспортируемые именованные функции из этого файла (а транзитивно — из
 * всех ре-экспортированных модулей) и деплоит каждую как отдельную
 * Cloud Function с тем же именем экспорта.
 *
 * Структура — по доменам (раздел 17 ТЗ — коллекции БД сгруппированы
 * по тем же доменам), а не плоским списком из раздела 18 ТЗ, чтобы
 * код было проще поддерживать. Полное соответствие "функция ТЗ → файл"
 * см. в README.md.
 */

// ВАЖНО: импорт конфигурации Firebase должен идти первым — он вызывает
// initializeApp() один раз, до того как любой модуль попытается
// обратиться к Firestore/Auth/Messaging.
import "./config/firebase";

export * from "./modules/users";
export * from "./modules/couples";
export * from "./modules/issues";
export * from "./modules/agreements";
export * from "./modules/checkins";
export * from "./modules/activities";
export * from "./modules/chores";
export * from "./modules/quizzes";
export * from "./modules/moderation";
export * from "./modules/notifications";
export * from "./modules/relationshipEvents";
export * from "./modules/admin";
