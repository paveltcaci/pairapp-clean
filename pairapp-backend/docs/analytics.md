# Аналитика (раздел 22 ТЗ)

Раздел 22 ТЗ перечисляет события аналитики (`user_registered`,
`couple_created`, `issue_created` и т.д.) с обезличенными параметрами.
Явно сказано: "Тексты проблем, сообщений и договорённостей никогда не
попадают в аналитические системы."

## Архитектурное решение

Аналитика реализуется **на клиенте через Firebase Analytics SDK**
(Flutter `firebase_analytics`), а не дублируется отдельным слоем на
backend. Причины:

1. Firebase Analytics — клиентский SDK по дизайну: он автоматически
   привязывает события к `app_instance_id`, версии приложения,
   платформе, без необходимости передавать это контекстом через каждый
   Cloud Function вызов.
2. Все события из таблицы раздела 22 соответствуют точкам, где клиент
   и так вызывает конкретную Cloud Function — то есть у клиента уже
   есть всё нужное для лога события `issue_created` (он сам вызвал
   `createIssue` с этими `category`/`importanceLevel`).
3. Дублирование на backend означало бы поддерживать аналитику в двух
   местах и решать конфликты атрибуции (один и тот же `issue_created`
   залогирован и клиентом, и функцией) без выигрыша в точности.

## Где backend всё же обязан помочь

Два события требуют данных, которые клиент **не может посчитать сам**
без лишнего запроса, потому что зависят от состояния, видимого только
на сервере в момент завершения операции:

- `issue_solved` (`days_to_solve`) — разница между `createdAt` и
  `solvedAt` проблемы. Backend возвращает оба timestamp'а в ответе
  `solveIssue`/`submitCheckinAnswer` (когда `result === 'success'`),
  клиент считает `days_to_solve` и логирует событие сам.
- `quiz_completed` (`match_percentage`) — уже возвращается полем
  `score.percentage` в ответе `submitQuizAnswers`, когда
  `bothCompleted === true`.

Других изменений backend не требует: для всех остальных событий
(`user_registered`, `couple_created`, `partner_joined`,
`issue_message_sent` (`type`), `agreement_created`,
`agreement_accepted`, `issue_reopened`, `activity_randomizer_used`
(`category`), `chore_randomizer_used`, `account_deleted`) у клиента уже
есть нужные параметры из своего же вызова — отдельный backend-эндпоинт
не добавляет точности, только сложность.
