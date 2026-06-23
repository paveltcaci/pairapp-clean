const PROJECT_ID = "projectlove-d23e9";
const AUTH_EMULATOR = "http://127.0.0.1:9099";
const FUNCTIONS_EMULATOR = `http://127.0.0.1:5001/${PROJECT_ID}/us-central1`;

const now = Date.now();

const users = {
  pasha: {
    email: `quiz_pasha_${now}@test.com`,
    password: "12345678",
    displayName: "Паша",
    gender: "male",
    birthDate: "2000-01-01",
    language: "ru",
  },
  andrey: {
    email: `quiz_andrey_${now}@test.com`,
    password: "12345678",
    displayName: "Андрей",
    gender: "male",
    birthDate: "2000-01-01",
    language: "ru",
  },
};

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function signUp(email, password) {
  const url = `${AUTH_EMULATOR}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key`;

  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      email,
      password,
      returnSecureToken: true,
    }),
  });

  const json = await res.json();

  if (!res.ok) {
    throw new Error(`Auth signUp failed: ${JSON.stringify(json, null, 2)}`);
  }

  return {
    uid: json.localId,
    idToken: json.idToken,
    email: json.email,
  };
}

async function callFunction(name, idToken, data = {}) {
  const url = `${FUNCTIONS_EMULATOR}/${name}`;

  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${idToken}`,
    },
    body: JSON.stringify({ data }),
  });

  const json = await res.json();

  if (!res.ok || json.error) {
    throw new Error(
      `Function ${name} failed:\n${JSON.stringify(json, null, 2)}`
    );
  }

  return json.result;
}

async function completeProfileWithRetry(authUser, profile) {
  for (let attempt = 1; attempt <= 5; attempt++) {
    try {
      return await callFunction("completeUserProfile", authUser.idToken, {
        displayName: profile.displayName,
        gender: profile.gender,
        birthDate: profile.birthDate,
        language: profile.language,
        acceptedTermsOfUse: true,
        acceptedPrivacyPolicy: true,
      });
    } catch (err) {
      console.log(`completeUserProfile попытка ${attempt} не прошла, ждём...`);

      if (attempt === 5) {
        throw err;
      }

      await sleep(1500);
    }
  }
}

async function main() {
  console.log("1. Создаём тестовых пользователей для квиза...");

  const pashaAuth = await signUp(users.pasha.email, users.pasha.password);
  const andreyAuth = await signUp(users.andrey.email, users.andrey.password);

  console.log("Паша UID:", pashaAuth.uid);
  console.log("Андрей UID:", andreyAuth.uid);

  console.log("\n2. Ждём Auth trigger createUserProfile...");
  await sleep(3000);

  console.log("\n3. Заполняем профили...");

  await completeProfileWithRetry(pashaAuth, users.pasha);
  await completeProfileWithRetry(andreyAuth, users.andrey);

  console.log("Профили заполнены.");

  console.log("\n4. Создаём пару...");

  const createdCouple = await callFunction("createCouple", pashaAuth.idToken);

  console.log("Couple ID:", createdCouple.coupleId);
  console.log("Invite code:", createdCouple.inviteCode);

  console.log("\n5. Андрей подключается к паре...");

  await callFunction("joinCoupleByInviteCode", andreyAuth.idToken, {
    inviteCode: createdCouple.inviteCode,
  });

  console.log("Андрей подключился.");

  console.log("\n6. Паша запускает квиз...");

  const quiz = await callFunction("startQuizSession", pashaAuth.idToken, {
    category: "values",
    questionCount: 2,
  });

  console.log("Quiz session ID:", quiz.sessionId);
  console.log("Question IDs:", quiz.questionIds);

  console.log("\n7. Паша отправляет ответы...");

  const pashaAnswers = {};
  quiz.questionIds.forEach((questionId, index) => {
    pashaAnswers[questionId] = index === 0 ? "same_answer" : "pasha_answer";
  });

  const pashaSubmit = await callFunction("submitQuizAnswers", pashaAuth.idToken, {
    sessionId: quiz.sessionId,
    answers: pashaAnswers,
  });

  console.log("Pasha submit result:", pashaSubmit);

  if (pashaSubmit.bothCompleted !== false) {
    throw new Error("После ответов первого партнёра bothCompleted должен быть false.");
  }

  console.log("\n8. Андрей отправляет ответы...");

  const andreyAnswers = {};
  quiz.questionIds.forEach((questionId, index) => {
    andreyAnswers[questionId] = index === 0 ? "same_answer" : "andrey_answer";
  });

  const andreySubmit = await callFunction("submitQuizAnswers", andreyAuth.idToken, {
    sessionId: quiz.sessionId,
    answers: andreyAnswers,
  });

  console.log("Andrey submit result:", andreySubmit);

  if (andreySubmit.bothCompleted !== true) {
    throw new Error("После ответов обоих партнёров bothCompleted должен быть true.");
  }

  if (!andreySubmit.score) {
    throw new Error("После завершения квиза должен появиться score.");
  }

  console.log("\nГОТОВО. Квиз-сценарий backend-а работает.");
  console.log("\nПроверь в Emulator UI:");
  console.log("- quiz_sessions");
  console.log("- quiz_answers");
  console.log("\nВажно:");
  console.log("- в quiz_sessions НЕ должно быть partnerAAnswers / partnerBAnswers");
  console.log("- в quiz_answers должно быть 2 документа с ответами");
}

main().catch((err) => {
  console.error("\nОШИБКА:");
  console.error(err.message);
  process.exit(1);
});