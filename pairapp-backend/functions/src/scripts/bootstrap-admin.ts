/**
 * scripts/bootstrap-admin.ts
 *
 * Одноразовый скрипт для назначения ПЕРВОГО администратора. Все
 * остальные admin-функции (setAdminRole и т.д.) требуют custom claim
 * 'role: admin', который физически не у кого взять при первом запуске
 * системы — отсюда необходимость отдельного скрипта, запускаемого
 * напрямую через Firebase Admin SDK с серверными credentials, а не
 * через клиентский Cloud Function вызов.
 *
 * Запуск (из папки functions, после `npm run build`):
 *   GOOGLE_APPLICATION_CREDENTIALS=./service-account.json \
 *     node lib/scripts/bootstrap-admin.js <uid>
 *
 * uid — Firebase Auth UID пользователя, который станет первым админом
 * (его нужно сначала зарегистрировать обычным образом через приложение
 * или Firebase Console).
 */
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

async function main() {
  const uid = process.argv[2];
  if (!uid) {
    console.error("Использование: node bootstrap-admin.js <uid>");
    process.exit(1);
  }

  initializeApp();
  await getAuth().setCustomUserClaims(uid, { role: "admin" });
  console.log(`Пользователю ${uid} назначена роль admin.`);
}

main().catch((err) => {
  console.error("Ошибка bootstrap-admin:", err);
  process.exit(1);
});
