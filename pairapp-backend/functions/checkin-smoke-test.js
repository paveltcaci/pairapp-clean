process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "127.0.0.1:8080";
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

const users = {
  pasha: {
    email: `checkin_pasha_${now}@test.com`,
    password: "12345678",
    displayName: "Паша",
    gender: "male",
    birthDate: "2000-01-01",
    language: "ru",
  },
  andrey: {
    email: `checkin_andrey_${now}@test.com`,
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

async function createIssueAgreementAndCheckin(pashaAuth, andreyAuth, title) {
  console.log(`\nСоздаём проблему: ${title}`);

  const issue = await callFunction("createIssue", pashaAuth.idToken, {
    title,
    description: "Тестовая проблема для проверки check-in.",
    feelings: ["sadness"],
    importanceLevel: 4,
    desiredOutcome: "Проверить работу договорённости.",
    category: "communication",
  });

  console.log("Issue ID:", issue.issueId);

  await callFunction("createIssueMessage", andreyAuth.idToken, {
    issueId: issue.issueId,
    type: "comment",
    text: "Ок, давай договоримся.",
  });

  const agreement = await callFunction("proposeAgreement", pashaAuth.idToken, {
    issueId: issue.issueId,
    title: `Договорённость по проблеме: ${title}`,
    description: "Тестовая договорённость.",
    checkIntervalDays: 7,
  });

  console.log("Agreement ID:", agreement.agreementId);

  const accepted = await callFunction("acceptAgreement", andreyAuth.idToken, {
    agreementId: agreement.agreementId,
  });

  console.log("Checkin ID:", accepted.checkinId);

  if (!accepted.becameActive || !accepted.checkinId) {
    throw new Error("После acceptAgreement договорённость должна стать active и создать checkin.");
  }

  return {
    issueId: issue.issueId,
    agreementId: agreement.agreementId,
    checkinId: accepted.checkinId,
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

async function main() {
  console.log("1. Создаём тестовых пользователей...");

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

  await callFunction("joinCoupleByInviteCode", andreyAuth.idToken, {
    inviteCode: createdCouple.inviteCode,
  });

  console.log("Андрей подключился к паре.");

  console.log("\n==============================");
  console.log("СЦЕНАРИЙ A: оба отвечают YES");
  console.log("==============================");

  const successCase = await createIssueAgreementAndCheckin(
    pashaAuth,
    andreyAuth,
    "Check-in success"
  );

  console.log("\nПаша отвечает YES...");

  const successFirst = await callFunction("submitCheckinAnswer", pashaAuth.idToken, {
    checkinId: successCase.checkinId,
    answer: "yes",
  });

  console.log("First answer result:", successFirst);

  assertEqual(successFirst.bothAnswered, false, "После первого ответа bothAnswered должен быть false");

  console.log("\nАндрей отвечает YES...");

  const successSecond = await callFunction("submitCheckinAnswer", andreyAuth.idToken, {
    checkinId: successCase.checkinId,
    answer: "yes",
  });

  console.log("Second answer result:", successSecond);

  assertEqual(successSecond.bothAnswered, true, "После второго ответа bothAnswered должен быть true");
  assertEqual(successSecond.result, "success", "Результат должен быть success");

  const successIssue = await readDoc("issues", successCase.issueId);
  const successAgreement = await readDoc("agreements", successCase.agreementId);
  const successCheckin = await readDoc("checkins", successCase.checkinId);

  assertEqual(successIssue.status, "solved", "Issue должен стать solved");
  assertEqual(successAgreement.status, "completed", "Agreement должен стать completed");
  assertEqual(successCheckin.status, "completed", "Checkin должен стать completed");
  assertEqual(successCheckin.result, "success", "Checkin result должен быть success");

  console.log("СЦЕНАРИЙ A OK");

  console.log("\n==============================");
  console.log("СЦЕНАРИЙ B: один отвечает NO");
  console.log("==============================");

  const failedCase = await createIssueAgreementAndCheckin(
    pashaAuth,
    andreyAuth,
    "Check-in failed"
  );

  console.log("\nПаша отвечает YES...");

  const failedFirst = await callFunction("submitCheckinAnswer", pashaAuth.idToken, {
    checkinId: failedCase.checkinId,
    answer: "yes",
  });

  console.log("First answer result:", failedFirst);

  assertEqual(failedFirst.bothAnswered, false, "После первого ответа bothAnswered должен быть false");

  console.log("\nАндрей отвечает NO...");

  const failedSecond = await callFunction("submitCheckinAnswer", andreyAuth.idToken, {
    checkinId: failedCase.checkinId,
    answer: "no",
  });

  console.log("Second answer result:", failedSecond);

  assertEqual(failedSecond.bothAnswered, true, "После второго ответа bothAnswered должен быть true");
  assertEqual(failedSecond.result, "failed", "Результат должен быть failed");

  const failedIssue = await readDoc("issues", failedCase.issueId);
  const failedAgreement = await readDoc("agreements", failedCase.agreementId);
  const failedCheckin = await readDoc("checkins", failedCase.checkinId);

  assertEqual(failedIssue.status, "reopened", "Issue должен стать reopened");
  assertEqual(failedAgreement.status, "failed", "Agreement должен стать failed");
  assertEqual(failedCheckin.status, "completed", "Checkin должен стать completed");
  assertEqual(failedCheckin.result, "failed", "Checkin result должен быть failed");

  console.log("СЦЕНАРИЙ B OK");

  console.log("\nГОТОВО. Check-in сценарии работают:");
  console.log("- оба YES → issue solved, agreement completed");
  console.log("- один NO → issue reopened, agreement failed");
}

main().catch((err) => {
  console.error("\nОШИБКА CHECKIN SMOKE TEST:");
  console.error(err.message);
  process.exit(1);
});