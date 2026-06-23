const { resolvePushText } = require("./lib/utils/push");

function assertEqual(actual, expected, label) {
  if (actual !== expected) {
    throw new Error(`${label}\nExpected: ${expected}\nActual: ${actual}`);
  }
}

function main() {
  console.log("1. Проверяем русский текст...");

  assertEqual(
    resolvePushText("push.newIssue.title", "ru"),
    "Новая проблема",
    "ru title"
  );

  assertEqual(
    resolvePushText("push.newIssue.body", "ru"),
    "Партнёр добавил новую тему для обсуждения.",
    "ru body"
  );

  console.log("ru OK");

  console.log("2. Проверяем английский текст...");

  assertEqual(
    resolvePushText("push.newIssue.title", "en"),
    "New issue",
    "en title"
  );

  assertEqual(
    resolvePushText("push.newIssue.body", "en"),
    "Your partner added a new topic to discuss.",
    "en body"
  );

  console.log("en OK");

  console.log("3. Проверяем параметры...");

  assertEqual(
    resolvePushText("push.relationshipDateProposed.body", "ru", {
      date: "2024-02-14",
    }),
    "Партнёр предложил дату начала отношений: 2024-02-14.",
    "ru params"
  );

  assertEqual(
    resolvePushText("push.relationshipDateProposed.body", "en", {
      date: "2024-02-14",
    }),
    "Your partner proposed a relationship start date: 2024-02-14.",
    "en params"
  );

  console.log("params OK");

  console.log("4. Проверяем fallback...");

  assertEqual(
    resolvePushText("unknown.key", "ru"),
    "unknown.key",
    "fallback key"
  );

  assertEqual(
    resolvePushText("push.newIssue.title", "ro"),
    "Новая проблема",
    "fallback language"
  );

  console.log("fallback OK");

  console.log("\nГОТОВО. Push-тексты локализуются нормально.");
}

main();