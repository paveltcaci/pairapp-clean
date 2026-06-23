/**
 * scripts/seed-content.ts
 *
 * Наполняет коллекции activities (builtin) и quiz_questions начальным
 * контентом — без этого приложение при первом запуске показывает пустые
 * экраны "Чем займёмся?" (раздел 11 ТЗ) и квизов (раздел 13 ТЗ).
 * Небольшой стартовый набор для проверки потоков; реальный контент-план
 * наполняется через административную панель (upsertBuiltinActivity /
 * upsertQuizQuestion, см. modules/admin/content.ts).
 *
 * Запуск (из папки functions, после `npm run build`):
 *   GOOGLE_APPLICATION_CREDENTIALS=./service-account.json \
 *     node lib/scripts/seed-content.js
 */
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

async function main() {
  initializeApp();
  const db = getFirestore();

  const activities: Array<{
    title: string;
    description: string;
    category: string;
    durationMinutes: number | null;
    budgetLevel: "free" | "low" | "medium" | "high";
  }> = [
    {
      title: "Вечер настольных игр",
      description: "Выберите 2-3 настольные игры и устройте вечер без телефонов.",
      category: "home",
      durationMinutes: 90,
      budgetLevel: "free",
    },
    {
      title: "Прогулка без телефонов",
      description: "30-минутная прогулка, во время которой телефоны остаются дома.",
      category: "outdoor",
      durationMinutes: 30,
      budgetLevel: "free",
    },
    {
      title: "Ужин в новом ресторане",
      description: "Найдите ресторан, в котором ещё не были вдвоём, и сходите туда.",
      category: "food",
      durationMinutes: 120,
      budgetLevel: "medium",
    },
    {
      title: "Готовим новое блюдо вместе",
      description: "Выберите рецепт, который никогда не готовили, и сделайте его вдвоём.",
      category: "home",
      durationMinutes: 60,
      budgetLevel: "low",
    },
    {
      title: "Поездка на выходные",
      description: "Спланируйте короткую поездку в город, где ещё не были вместе.",
      category: "travel",
      durationMinutes: null,
      budgetLevel: "high",
    },
  ];

  const batch1 = db.batch();
  for (const activity of activities) {
    const ref = db.collection("activities").doc();
    batch1.set(ref, {
      id: ref.id,
      coupleId: null,
      title: activity.title,
      description: activity.description,
      category: activity.category,
      durationMinutes: activity.durationMinutes,
      budgetLevel: activity.budgetLevel,
      source: "builtin",
      createdBy: null,
      isActive: true,
      createdAt: Timestamp.now(),
    });
  }
  await batch1.commit();
  console.log(`Создано ${activities.length} встроенных активностей.`);

  const quizQuestions: Array<{
    category: string;
    questionText: { ru: string; en: string };
    answerType: "text" | "single_choice" | "multi_choice";
    options: Array<{ id: string; text: { ru: string; en: string } }> | null;
  }> = [
    {
      category: "values",
      questionText: {
        ru: "Что для тебя важнее в отношениях: стабильность или спонтанность?",
        en: "What matters more to you in a relationship: stability or spontaneity?",
      },
      answerType: "single_choice",
      options: [
        { id: "stability", text: { ru: "Стабильность", en: "Stability" } },
        { id: "spontaneity", text: { ru: "Спонтанность", en: "Spontaneity" } },
      ],
    },
    {
      category: "values",
      questionText: {
        ru: "Какой подарок ты бы предпочёл(-ла) на день рождения?",
        en: "What kind of birthday gift would you prefer?",
      },
      answerType: "single_choice",
      options: [
        { id: "experience", text: { ru: "Впечатление/поездку", en: "An experience/trip" } },
        { id: "thing", text: { ru: "Вещь", en: "A physical item" } },
      ],
    },
    {
      category: "lifestyle",
      questionText: {
        ru: "Сколько вечеров в неделю ты хочешь проводить вместе?",
        en: "How many evenings a week do you want to spend together?",
      },
      answerType: "text",
      options: null,
    },
  ];

  const batch2 = db.batch();
  for (const q of quizQuestions) {
    const ref = db.collection("quiz_questions").doc();
    batch2.set(ref, {
      id: ref.id,
      category: q.category,
      questionText: q.questionText,
      answerType: q.answerType,
      options: q.options,
      language: null,
      isDefault: true,
      isActive: true,
      createdAt: Timestamp.now(),
    });
  }
  await batch2.commit();
  console.log(`Создано ${quizQuestions.length} вопросов квиза.`);
}

main().catch((err) => {
  console.error("Ошибка seed-content:", err);
  process.exit(1);
});
