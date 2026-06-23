    process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "127.0.0.1:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || "127.0.0.1:9099";
process.env.GCLOUD_PROJECT = process.env.GCLOUD_PROJECT || "projectlove-d23e9";

const admin = require("firebase-admin");

const PROJECT_ID = "projectlove-d23e9";
const AUTH_EMULATOR = "http://127.0.0.1:9099";
const FUNCTIONS_EMULATOR = `http://127.0.0.1:5001/${PROJECT_ID}/us-central1`;

if (!admin.apps.length) {
  admin.initializeApp({
    projectId: PROJECT_ID,
  });
}

const db = admin.firestore();

const now = Date.now();

function makeUsers(prefix) {
  return {
    pasha: {
      email: `${prefix}_pasha_${now}@test.com`,
      password: "12345678",
      displayName: "Паша",
      gender: "male",
      birthDate: "2000-01-01",
      language: "ru",
    },
    andrey: {
      email: `${prefix}_andrey_${now}@test.com`,
      password: "12345678",
      displayName: "Андрей",
      gender: "male",
      birthDate: "2000-01-01",
      language: "ru",
    },
  };
}

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

async function expectFunctionFails(name, idToken, data, label) {
  try {
    await callFunction(name, idToken, data);
  } catch (err) {
    console.log(`${label}: OK, функция отказала как надо.`);
    return;
  }

  throw new Error(`${label}: функция должна была отказать, но прошла.`);
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

async function createPairWithTwoUsers(prefix) {
  const users = makeUsers(prefix);

  const pashaAuth = await signUp(users.pasha.email, users.pasha.password);
  const andreyAuth = await signUp(users.andrey.email, users.andrey.password);

  await sleep(3000);

  await completeProfileWithRetry(pashaAuth, users.pasha);
  await completeProfileWithRetry(andreyAuth, users.andrey);

  const createdCouple = await callFunction("createCouple", pashaAuth.idToken);

  await callFunction("joinCoupleByInviteCode", andreyAuth.idToken, {
    inviteCode: createdCouple.inviteCode,
  });

  return {
    pashaAuth,
    andreyAuth,
    coupleId: createdCouple.coupleId,
  };
}

async function createIssueAndMessage(pashaAuth, andreyAuth) {
  const issue = await callFunction("createIssue", pashaAuth.idToken, {
    title: "Тестовая проблема для жалобы",
    description: "Проверяем createReport и blockUser.",
    feelings: ["sadness"],
    importanceLevel: 4,
    desiredOutcome: "Проверить безопасность.",
    category: "communication",
  });

  const message = await callFunction("createIssueMessage", andreyAuth.idToken, {
    issueId: issue.issueId,
    type: "comment",
    text: "Тестовое сообщение, на которое можно пожаловаться.",
  });

  return {
    issueId: issue.issueId,
    messageId: message.messageId,
  };
}

async function readDoc(collection, id) {
  const snap = await db.collection(collection).doc(id).get();

  if (!snap.exists) {
    throw new Error(`Документ ${collection}/${id} не найден.`);
  }

  return snap.data();
}

function assertEqual(actual, expected, label) {
  if (actual !== expected) {
    throw new Error(`${label}\nExpected: ${expected}\nActual: ${actual}`);
  }
}

async function assertAuthUserDeleted(uid) {
  try {
    await admin.auth().getUser(uid);
  } catch (err) {
    console.log("Auth user удалён: OK");
    return;
  }

  throw new Error("Firebase Auth user должен быть удалён, но всё ещё существует.");
}

async function runReportAndBlockScenario() {
  console.log("\n==============================");
  console.log("СЦЕНАРИЙ A: жалоба + блокировка");
  console.log("==============================");

  const { pashaAuth, andreyAuth, coupleId } = await createPairWithTwoUsers(
    "moderation_block"
  );

  console.log("Couple ID:", coupleId);

  const { issueId, messageId } = await createIssueAndMessage(
    pashaAuth,
    andreyAuth
  );

  console.log("Issue ID:", issueId);
  console.log("Message ID:", messageId);

  console.log("\nПаша создаёт жалобу на сообщение...");

  const report = await callFunction("createReport", pashaAuth.idToken, {
    targetType: "message",
    targetId: messageId,
    reason: "abuse",
    comment: "Тестовая жалоба.",
  });

  console.log("Report ID:", report.reportId);

  const reportDoc = await readDoc("reports", report.reportId);

  assertEqual(reportDoc.reporterId, pashaAuth.uid, "reporterId должен быть Паша");
  assertEqual(reportDoc.reportedUserId, andreyAuth.uid, "reportedUserId должен быть Андрей");
  assertEqual(reportDoc.coupleId, coupleId, "report.coupleId должен совпадать");
  assertEqual(reportDoc.status, "pending", "report.status должен быть pending");

  console.log("createReport OK");

  console.log("\nПаша блокирует партнёра по этой жалобе...");

  const block = await callFunction("blockUser", pashaAuth.idToken, {
    reportId: report.reportId,
  });

  console.log("Block result:", block);

  const coupleAfterBlock = await readDoc("couples", coupleId);

  assertEqual(coupleAfterBlock.status, "blocked", "couple.status должен стать blocked");

  console.log("blockUser OK");

  console.log("\nПроверяем, что после блокировки нельзя писать в проблему...");

  await expectFunctionFails(
    "createIssueMessage",
    andreyAuth.idToken,
    {
      issueId,
      type: "comment",
      text: "Это сообщение не должно пройти после блокировки.",
    },
    "createIssueMessage after block"
  );

  console.log("СЦЕНАРИЙ A OK");
}

async function runDeleteAccountScenario() {
  console.log("\n==============================");
  console.log("СЦЕНАРИЙ B: удаление аккаунта");
  console.log("==============================");

  const { pashaAuth, andreyAuth, coupleId } = await createPairWithTwoUsers(
    "moderation_delete"
  );

  console.log("Couple ID:", coupleId);
  console.log("Pasha UID:", pashaAuth.uid);
  console.log("Andrey UID:", andreyAuth.uid);

  console.log("\nПроверяем, что без confirm удаление не проходит...");

  await expectFunctionFails(
    "deleteAccount",
    pashaAuth.idToken,
    {
      confirm: false,
    },
    "deleteAccount without confirm"
  );

  console.log("\nПаша удаляет аккаунт с confirm:true...");

  const deleted = await callFunction("deleteAccount", pashaAuth.idToken, {
    confirm: true,
  });

  console.log("Delete result:", deleted);

  const pashaDoc = await readDoc("users", pashaAuth.uid);
  const coupleDoc = await readDoc("couples", coupleId);
  const andreyDoc = await readDoc("users", andreyAuth.uid);

  assertEqual(pashaDoc.isDeleted, true, "users/{pasha}.isDeleted должен быть true");
  assertEqual(pashaDoc.currentCoupleId, null, "users/{pasha}.currentCoupleId должен быть null");
  assertEqual(pashaDoc.displayName, "Удалённый пользователь", "displayName должен быть обезличен");
  assertEqual(coupleDoc.status, "disconnected", "couple.status должен стать disconnected");
  assertEqual(andreyDoc.currentCoupleId, coupleId, "Андрей должен остаться привязан к паре");

  await assertAuthUserDeleted(pashaAuth.uid);

  console.log("СЦЕНАРИЙ B OK");
}

async function main() {
  console.log("Запускаем moderation/account smoke-test...");

  await runReportAndBlockScenario();
  await runDeleteAccountScenario();

  console.log("\nГОТОВО. Жалобы, блокировка и удаление аккаунта работают:");
  console.log("- createReport создаёт pending-жалобу");
  console.log("- blockUser переводит пару в blocked");
  console.log("- после blocked нельзя отправлять сообщения");
  console.log("- deleteAccount требует confirm:true");
  console.log("- deleteAccount обезличивает пользователя");
  console.log("- deleteAccount переводит пару в disconnected");
  console.log("- deleteAccount удаляет Firebase Auth user");
}

main().catch((err) => {
  console.error("\nОШИБКА MODERATION SMOKE TEST:");
  console.error(err.message);
  process.exit(1);
});