const PROJECT_ID = "projectlove-d23e9";
const AUTH_EMULATOR = "http://127.0.0.1:9099";
const FUNCTIONS_EMULATOR = `http://127.0.0.1:5001/${PROJECT_ID}/us-central1`;

const now = Date.now();

const users = {
  pasha: {
    email: `pasha_${now}@test.com`,
    password: "12345678",
    displayName: "Паша",
    gender: "male",
    birthDate: "2000-01-01",
    language: "ru",
  },
  andrey: {
    email: `andrey_${now}@test.com`,
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
      console.log(
        `completeUserProfile попытка ${attempt} не прошла, ждём...`
      );

      if (attempt === 5) {
        throw err;
      }

      await sleep(1500);
    }
  }
}

async function main() {
  console.log("1. Создаём тестовых пользователей...");

  const pashaAuth = await signUp(users.pasha.email, users.pasha.password);
  const andreyAuth = await signUp(users.andrey.email, users.andrey.password);

  console.log("Паша UID:", pashaAuth.uid);
  console.log("Андрей UID:", andreyAuth.uid);

  console.log("\n2. Ждём Auth trigger createUserProfile...");
  await sleep(3000);

  console.log("\n3. Заполняем профили пользователей...");

  await completeProfileWithRetry(pashaAuth, users.pasha);
  await completeProfileWithRetry(andreyAuth, users.andrey);

  console.log("Профили заполнены.");

  console.log("\n4. Паша создаёт пару...");

  const createdCouple = await callFunction("createCouple", pashaAuth.idToken);

  console.log("Couple ID:", createdCouple.coupleId);
  console.log("Invite code:", createdCouple.inviteCode);

  console.log("\n5. Андрей подключается по invite-коду...");

  const joinedCouple = await callFunction(
    "joinCoupleByInviteCode",
    andreyAuth.idToken,
    {
      inviteCode: createdCouple.inviteCode,
    }
  );

  console.log("Андрей подключился к паре:", joinedCouple.coupleId);

  console.log("\n6. Паша создаёт проблему...");

  const issue = await callFunction("createIssue", pashaAuth.idToken, {
    title: "Мы мало проводим времени вместе",
    description: "Мне кажется, что последнее время мы редко бываем вдвоём.",
    feelings: ["loneliness", "sadness"],
    importanceLevel: 4,
    desiredOutcome: "Хочу договориться хотя бы об одном вечере в неделю.",
    category: "time_together",
  });

  console.log("Issue ID:", issue.issueId);

  console.log("\n7. Андрей отвечает в проблеме...");

  const message = await callFunction(
    "createIssueMessage",
    andreyAuth.idToken,
    {
      issueId: issue.issueId,
      type: "comment",
      text: "Я понимаю. Мы правда оба много работаем, но давай попробуем выделить вечер.",
    }
  );

  console.log("Message ID:", message.messageId);
  console.log("New issue status:", message.newStatus);

  console.log("\n8. Паша предлагает договорённость...");

  const agreement = await callFunction("proposeAgreement", pashaAuth.idToken, {
    issueId: issue.issueId,
    title: "Один вечер в неделю только для нас",
    description: "Каждую пятницу вечером гуляем, смотрим фильм или ужинаем вместе.",
    checkIntervalDays: 7,
  });

  console.log("Agreement ID:", agreement.agreementId);

  console.log("\n9. Андрей принимает договорённость...");

  const accepted = await callFunction(
    "acceptAgreement",
    andreyAuth.idToken,
    {
      agreementId: agreement.agreementId,
    }
  );

  console.log("Agreement accepted:", accepted);

  console.log("\nГОТОВО. Базовый MVP-сценарий backend-а работает.");
  console.log("\nПроверь в Emulator UI коллекции:");
  console.log("- users");
  console.log("- couples");
  console.log("- issues");
  console.log("- issue_messages");
  console.log("- agreements");
  console.log("- checkins");
}

main().catch((err) => {
  console.error("\nОШИБКА:");
  console.error(err.message);
  process.exit(1);
});