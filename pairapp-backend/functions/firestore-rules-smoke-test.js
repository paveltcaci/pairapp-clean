const fs = require("fs");
const path = require("path");

const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");

const {
  doc,
  setDoc,
  getDoc,
  updateDoc,
} = require("firebase/firestore");

const PROJECT_ID = `rules-test-${Date.now()}`;

async function main() {
  console.log("1. Загружаем firestore.rules...");

  const rulesPath = path.join(__dirname, "..", "firestore", "firestore.rules");
  const rules = fs.readFileSync(rulesPath, "utf8");

  const testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      host: "127.0.0.1",
      port: 8080,
      rules,
    },
  });

  await testEnv.clearFirestore();

  console.log("2. Создаём тестовые документы без security rules...");

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await setDoc(doc(db, "users/pasha"), {
      id: "pasha",
      email: "pasha@test.com",
      displayName: "Паша",
      currentCoupleId: "couple1",
      isDeleted: false,
      isBlocked: false,
    });

    await setDoc(doc(db, "users/andrey"), {
      id: "andrey",
      email: "andrey@test.com",
      displayName: "Андрей",
      currentCoupleId: "couple1",
      isDeleted: false,
      isBlocked: false,
    });

    await setDoc(doc(db, "users/outsider"), {
      id: "outsider",
      email: "outsider@test.com",
      displayName: "Чужой",
      currentCoupleId: "couple2",
      isDeleted: false,
      isBlocked: false,
    });

    await setDoc(doc(db, "couples/couple1"), {
      id: "couple1",
      partnerAId: "pasha",
      partnerBId: "andrey",
      status: "active",
      inviteCode: "ABC123",
      inviteCodeUsed: true,
    });

    await setDoc(doc(db, "couples/couple2"), {
      id: "couple2",
      partnerAId: "outsider",
      partnerBId: null,
      status: "active",
      inviteCode: "ZZZ999",
      inviteCodeUsed: false,
    });

    await setDoc(doc(db, "issues/issue1"), {
      id: "issue1",
      coupleId: "couple1",
      authorId: "pasha",
      title: "Тестовая проблема",
      status: "open",
    });

    await setDoc(doc(db, "issue_messages/message1"), {
      id: "message1",
      issueId: "issue1",
      coupleId: "couple1",
      authorId: "pasha",
      type: "comment",
      text: "Тестовое сообщение",
      isDeleted: false,
    });

    await setDoc(doc(db, "agreements/agreement1"), {
      id: "agreement1",
      coupleId: "couple1",
      issueId: "issue1",
      title: "Тестовая договорённость",
      status: "active",
    });

    await setDoc(doc(db, "checkins/checkin1"), {
      id: "checkin1",
      agreementId: "agreement1",
      issueId: "issue1",
      coupleId: "couple1",
      status: "pending",
      result: null,
    });

    await setDoc(doc(db, "reports/report1"), {
      id: "report1",
      reporterId: "pasha",
      reportedUserId: "andrey",
      coupleId: "couple1",
      targetType: "message",
      targetId: "message1",
      reason: "abuse",
      status: "pending",
    });

    await setDoc(doc(db, "quiz_sessions/sessionPending"), {
      id: "sessionPending",
      coupleId: "couple1",
      category: "values",
      createdBy: "pasha",
      status: "waiting_partner_b",
      partnerAId: "pasha",
      partnerBId: "andrey",
      questionIds: ["q1", "q2"],
      score: null,
    });

    await setDoc(doc(db, "quiz_answers/sessionPending_pasha"), {
      id: "sessionPending_pasha",
      sessionId: "sessionPending",
      coupleId: "couple1",
      userId: "pasha",
      slot: "A",
      answers: {
        q1: "answer from pasha",
        q2: "answer from pasha 2",
      },
    });

    await setDoc(doc(db, "quiz_answers/sessionPending_andrey"), {
      id: "sessionPending_andrey",
      sessionId: "sessionPending",
      coupleId: "couple1",
      userId: "andrey",
      slot: "B",
      answers: {
        q1: "secret answer from andrey",
        q2: "secret answer from andrey 2",
      },
    });

    await setDoc(doc(db, "quiz_sessions/sessionCompleted"), {
      id: "sessionCompleted",
      coupleId: "couple1",
      category: "values",
      createdBy: "pasha",
      status: "completed",
      partnerAId: "pasha",
      partnerBId: "andrey",
      questionIds: ["q1", "q2"],
      score: {
        matchCount: 1,
        totalCount: 2,
        percentage: 50,
      },
    });

    await setDoc(doc(db, "quiz_answers/sessionCompleted_andrey"), {
      id: "sessionCompleted_andrey",
      sessionId: "sessionCompleted",
      coupleId: "couple1",
      userId: "andrey",
      slot: "B",
      answers: {
        q1: "visible after completed",
        q2: "visible after completed 2",
      },
    });
  });

  const pashaDb = testEnv.authenticatedContext("pasha").firestore();
  const andreyDb = testEnv.authenticatedContext("andrey").firestore();
  const outsiderDb = testEnv.authenticatedContext("outsider").firestore();
  const adminDb = testEnv
    .authenticatedContext("admin", { role: "admin" })
    .firestore();

  console.log("3. Проверяем users...");

  await assertSucceeds(getDoc(doc(pashaDb, "users/pasha")));
  await assertSucceeds(getDoc(doc(pashaDb, "users/andrey")));
  await assertFails(getDoc(doc(pashaDb, "users/outsider")));

  console.log("users OK");

  console.log("4. Проверяем couples...");

  await assertSucceeds(getDoc(doc(pashaDb, "couples/couple1")));
  await assertSucceeds(getDoc(doc(andreyDb, "couples/couple1")));
  await assertFails(getDoc(doc(outsiderDb, "couples/couple1")));

  console.log("couples OK");

  console.log("5. Проверяем issues / messages / agreements / checkins...");

  await assertSucceeds(getDoc(doc(pashaDb, "issues/issue1")));
  await assertSucceeds(getDoc(doc(andreyDb, "issues/issue1")));
  await assertFails(getDoc(doc(outsiderDb, "issues/issue1")));

  await assertSucceeds(getDoc(doc(pashaDb, "issue_messages/message1")));
  await assertFails(getDoc(doc(outsiderDb, "issue_messages/message1")));

  await assertSucceeds(getDoc(doc(pashaDb, "agreements/agreement1")));
  await assertFails(getDoc(doc(outsiderDb, "agreements/agreement1")));

  await assertSucceeds(getDoc(doc(pashaDb, "checkins/checkin1")));
  await assertFails(getDoc(doc(outsiderDb, "checkins/checkin1")));

  console.log("issues/messages/agreements/checkins OK");

  console.log("6. Проверяем запрет прямой записи клиентом...");

  await assertFails(
    setDoc(doc(pashaDb, "issues/evilIssue"), {
      id: "evilIssue",
      coupleId: "couple1",
      title: "Нельзя писать напрямую",
    })
  );

  await assertFails(
    updateDoc(doc(pashaDb, "issues/issue1"), {
      title: "Нельзя менять напрямую",
    })
  );

  console.log("write protection OK");

  console.log("7. Проверяем reports...");

  await assertSucceeds(getDoc(doc(pashaDb, "reports/report1")));
  await assertFails(getDoc(doc(andreyDb, "reports/report1")));
  await assertFails(getDoc(doc(outsiderDb, "reports/report1")));
  await assertSucceeds(getDoc(doc(adminDb, "reports/report1")));

  console.log("reports OK");

  console.log("8. Проверяем quiz_answers privacy...");

  // Паша может читать свой ответ.
  await assertSucceeds(getDoc(doc(pashaDb, "quiz_answers/sessionPending_pasha")));

  // Паша НЕ должен читать ответ Андрея, пока квиз не completed.
  await assertFails(getDoc(doc(pashaDb, "quiz_answers/sessionPending_andrey")));

  // После completed Паша может читать ответ Андрея для экрана результата.
  await assertSucceeds(
    getDoc(doc(pashaDb, "quiz_answers/sessionCompleted_andrey"))
  );

  // Чужой пользователь не должен читать даже completed-ответы чужой пары.
  await assertFails(
    getDoc(doc(outsiderDb, "quiz_answers/sessionCompleted_andrey"))
  );

  console.log("quiz_answers privacy OK");

  await testEnv.cleanup();

  console.log("\nГОТОВО. Firestore rules базово защищают данные пары.");
}

main().catch((err) => {
  console.error("\nОШИБКА FIRESTORE RULES TEST:");
  console.error(err);
  process.exit(1);
});