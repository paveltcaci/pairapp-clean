import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { getAuth } from "firebase-admin/auth";

// initializeApp() должен вызываться один раз за процесс — этот модуль
// импортируется первым во всех точках входа (см. src/index.ts).
export const app = initializeApp();

export const db = getFirestore(app);
export const messaging = getMessaging(app);
export const auth = getAuth(app);

// FieldValue.serverTimestamp() ломается на эмуляторе, если не включены
// timestampsInSnapshots — на новых версиях SDK это уже дефолт, оставлено
// явно на случай даунгрейда зависимостей.
db.settings({ ignoreUndefinedProperties: true });

/** Типобезопасные имена коллекций верхнего уровня (раздел 17 ТЗ). */
export const Collections = {
  users: "users",
  couples: "couples",
  issues: "issues",
  issueMessages: "issue_messages",
  agreements: "agreements",
  checkins: "checkins",
  activities: "activities",
  activityHistory: "activity_history",
  choreTasks: "chore_tasks",
  choreSpins: "chore_spins",
  quizQuestions: "quiz_questions",
  quizSessions: "quiz_sessions",
  quizAnswers: "quiz_answers",
  relationshipEvents: "relationship_events",
  reports: "reports",
  subscriptions: "subscriptions",
  wishlistItems: "wishlist_items",
} as const;
