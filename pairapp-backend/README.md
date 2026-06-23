# PairApp Backend (Firebase: Auth + Firestore + Cloud Functions + FCM)

Backend для мобильного приложения для пар по ТЗ `TZ_PairApp_v1.docx`.
Стек: **Firebase** (Auth, Firestore, Cloud Functions v2, Cloud Messaging,
Storage), язык — **TypeScript**.

> Этот backend разрабатывался в среде без доступа к интернету (npm install
> не может скачать пакеты). Весь код прошёл синтаксическую проверку через
> TypeScript Compiler API и проверку типов через самодельные `.d.ts`-стабы
> для firebase-admin/firebase-functions/zod, которые приближённо
> воспроизводят их публичный API. **Перед первым деплоем обязательно
> выполните `npm install && npm run build` в папке `functions/` в среде с
> интернетом** — это настоящая компиляция против реальных пакетов и
> единственный надёжный способ поймать опечатки в сигнатурах внешних
> библиотек, которые стабы не могли воспроизвести 1-в-1.

## Структура репозитория

```
pairapp-backend/
├── firebase.json              # конфигурация Firebase-проекта
├── .firebaserc                 # алиас проекта (поменяйте "pairapp-dev" на свой)
├── firestore/
│   ├── firestore.rules         # security rules (раздел 21 ТЗ)
│   └── firestore.indexes.json  # композитные индексы
├── storage.rules               # правила для аватаров (раздел 15.2 ТЗ)
├── docs/
│   └── analytics.md            # архитектурное решение по разделу 22 ТЗ
└── functions/
    ├── package.json
    ├── tsconfig.json
    └── src/
        ├── index.ts             # точка входа, ре-экспортирует все модули
        ├── config/firebase.ts   # initializeApp(), ссылки на коллекции
        ├── types/               # модели данных — раздел 17 ТЗ
        ├── utils/               # auth, ошибки, push, валидация, couple-context
        ├── modules/             # бизнес-логика по доменам (см. таблицу ниже)
        └── scripts/             # bootstrap-admin.ts, seed-content.ts
```

## Установка и деплой

```bash
cd pairapp-backend
firebase login
# поменяйте "pairapp-dev" в .firebaserc на реальный Project ID
cd functions
npm install
npm run build
cd ..
firebase deploy --only firestore:rules,firestore:indexes,storage,functions
```

Назначить первого администратора (нужен один раз — см.
`functions/src/scripts/bootstrap-admin.ts`):
```bash
cd functions && npm run build
GOOGLE_APPLICATION_CREDENTIALS=./service-account.json \
  node lib/scripts/bootstrap-admin.js <uid первого админа>
```

Наполнить начальный контент (встроенные активности + вопросы квиза, см.
`functions/src/scripts/seed-content.ts`):
```bash
GOOGLE_APPLICATION_CREDENTIALS=./service-account.json \
  node lib/scripts/seed-content.js
```

Локальная разработка с эмуляторами:
```bash
cd functions && npm run serve
```

## Трассируемость: функция ТЗ (раздел 18) → файл

| Функция в ТЗ | Реализована в | Примечание |
|---|---|---|
| `createUserProfile` | `modules/users/createUserProfile.ts` | Auth-триггер (`onCreate`), не callable |
| — | `modules/users/completeUserProfile.ts` | **Добавлено**: дозаполнение анкеты + проверка возраста 16+ (раздел 5.3 ТЗ) |
| `createCouple` | `modules/couples/createCouple.ts` | |
| `joinCoupleByInviteCode` | `modules/couples/joinCoupleByInviteCode.ts` | |
| `regenerateInviteCode` | `modules/couples/regenerateInviteCode.ts` | |
| `leaveCouple` | `modules/couples/leaveCouple.ts` | |
| `updateRelationshipStartDate` | `modules/couples/relationshipDate.ts` | |
| `confirmRelationshipStartDate` | `modules/couples/relationshipDate.ts` | |
| — | `modules/couples/relationshipCounter.ts` | **Добавлено**: `getRelationshipCounter` — счётчик дней/лет + факты (раздел 10 ТЗ) |
| `createIssue` | `modules/issues/createIssue.ts` | |
| `updateIssue` | `modules/issues/updateIssue.ts` | Только автор может редактировать (см. "Архитектурные решения") |
| `createIssueMessage` | `modules/issues/createIssueMessage.ts` | Авто-переход статуса проблемы по типу сообщения |
| `solveIssue` | `modules/issues/solveIssue.ts` | Explicit-путь без check-in |
| `reopenIssue` | `modules/issues/reopenIssue.ts` | |
| `proposeAgreement` | `modules/agreements/proposeAgreement.ts` | Автор сразу = `accepted_by_one` |
| `acceptAgreement` | `modules/agreements/acceptAgreement.ts` | При `accepted_by_both` создаёт первый Checkin |
| `createCheckin` | `modules/checkins/createCheckin.ts` | Scheduled-функция (см. "Архитектурные решения") |
| `submitCheckinAnswer` | `modules/checkins/submitCheckinAnswer.ts` | |
| `processCheckinResult` | встроена в `submitCheckinAnswer.ts` | Не отдельная функция — см. комментарий в файле |
| `createActivity` | `modules/activities/createActivity.ts` | |
| `spinActivityRandomizer` | `modules/activities/spinActivityRandomizer.ts` | |
| — | `modules/activities/spinActivityRandomizer.ts` (`acceptActivity`) | **Добавлено**: фиксация выбора в `activity_history` |
| `createChoreTask` | `modules/chores/createChoreTask.ts` | |
| `spinChoreRandomizer` | `modules/chores/spinChoreRandomizer.ts` | Алгоритм честного выбора — см. комментарий в файле |
| `startQuizSession` | `modules/quizzes/startQuizSession.ts` | |
| `submitQuizAnswers` | `modules/quizzes/submitQuizAnswers.ts` | |
| `calculateQuizResult` | встроена в `submitQuizAnswers.ts` | Аналогично `processCheckinResult` |
| `createReport` | `modules/moderation/createReport.ts` | |
| `blockUser` | `modules/moderation/blockUser.ts` | Блокирует **пару** (`couple.status`), не профиль — см. ниже |
| `sendPushNotification` | `utils/push.ts` (`sendPushToUser`/`sendPushToUsers`) | Внутренний хелпер, вызывается из всех модулей |
| `deleteAccount` | `modules/users/deleteAccount.ts` | Обезличивание + удаление Auth-записи |
| — | `modules/notifications/notifyAnniversaries.ts` | **Добавлено**: scheduled push на годовщину (раздел 14 ТЗ) |
| — | `modules/relationshipEvents/events.ts` | **Добавлено**: CRUD для `relationship_events` (раздел 17.13 ТЗ существует в схеме, но не было функции создания) |
| — | `modules/admin/*.ts` | **Добавлено**: вся административная панель (раздел 23 ТЗ) — `reviewReport`, `setAdminUserBlocked`, `setAdminRole`, `upsertBuiltinActivity`, `setActivityActive`, `upsertQuizQuestion`, `setQuizQuestionActive` |

"Добавлено" = функция не была явно перечислена в разделе 18 ТЗ, но
требовалась для того, чтобы код из других разделов ТЗ (схема данных,
экраны, разделы 14/22/23) был реализуемым целиком, а не только частично.

## Архитектурные решения, требующие вашего внимания

ТЗ местами описывает поведение качественно ("вероятность повышается",
"показывается подсказка"), а схема и список функций не всегда дают
однозначный ответ на пограничные случаи. Ниже — решения, которые я
принял самостоятельно, с обоснованием. Каждое также продублировано
комментарием в соответствующем файле — ищите по тем же ключевым словам.

1. **Кто может редактировать карточку проблемы (`updateIssue`)** — только
   автор. ТЗ не уточняет; партнёр должен реагировать через ветку
   обсуждения, а не правкой чужой карточки.

2. **Авто-принятие своего предложения договорённости (`proposeAgreement`)**
   — автор сразу в `accepted_by_one`, статус `proposed` из раздела 9.3 ТЗ
   физически не используется. Альтернатива — оставлять `proposed`, пока
   автор не подтвердит сам, добавила бы лишний шаг без пользы.

3. **`blockUser` блокирует пару, не профиль.** `couple.status = 'blocked'`
   (пользовательская блокировка партнёра, раздел 16.2 ТЗ) и
   `users.isBlocked` (административная блокировка, раздел 23.2 ТЗ) — это
   два разных механизма с разным владельцем действия. См. комментарий в
   `modules/moderation/blockUser.ts`.

4. **`createCheckin` не создаёт документ Checkin** — он создаётся заранее,
   в момент `acceptAgreement`, потому что дата проверки известна сразу.
   Scheduled-функция `createCheckin` (название сохранено для
   трассируемости с ТЗ) сканирует `pending`-чекины с подошедшим сроком и
   рассылает push — то есть по факту "активирует уведомление", а не
   создаёт запись.

5. **`processCheckinResult` и `calculateQuizResult` не отдельные
   функции** — они выполняются как последний шаг той же транзакции, что
   и `submitCheckinAnswer`/`submitQuizAnswers`, как только получен второй
   ответ. Результат детерминирован по таблице ТЗ, отдельный
   пользовательский вызов для "запуска" вычисления не нужен.

6. **Алгоритм честного выбора в `spinChoreRandomizer`** — ТЗ описывает
   поведение качественно ("если партнёр выпадал два раза подряд,
   вероятность второго повышается"), без точной формулы. Реализован
   взвешенный выбор на основе streak в последних 5 спинах (вес
   `1 + streak * 0.5` для "невезучего" партнёра). Формула — наша
   интерпретация; если продукт хочет другую кривую вероятности, меняется
   в одной функции `computeFairWeights`.

7. **Push отправляются с ключами локализации, а не готовым текстом**
   (`titleKey: "push.newIssue.title"`). Раздел 4 ТЗ разделяет "язык
   интерфейса" (переводится) от "контента, который вводят партнёры" (не
   переводится) — push-уведомления системные, поэтому переводятся на
   клиенте по ключу, на языке конкретного получателя, а не отправителя.
   **Клиент должен держать словарь этих ключей** (см. список в
   `utils/push.ts` и местах вызова `sendPushToUser`).

8. **Категории/чувства/etc. хранятся как английские snake_case ключи**
   (`"time_together"`, `"household"`), а не русские строки из текста ТЗ.
   Стандартная практика для мультиязычного продукта — UI переводит по
   ключу. Полный список — `types/common.ts`
   (`ISSUE_CATEGORIES`, `ISSUE_FEELINGS`).

9. **Право на удаление/обезличивание (`deleteAccount`)** — документ
   `users` не удаляется физически, только обезличивается (email/имя
   заменяются плейсхолдером), потому что другие коллекции хранят
   `authorId`/`proposedBy` и т.п., и полное удаление сломало бы историю
   партнёра. Firebase Auth-запись удаляется физически — это и есть точка
   отказа доступа.

10. **`fcmTokens: string[]` вместо `fcmToken: string|null` из раздела
    17.1 ТЗ** — поддержка нескольких устройств одного пользователя.
    Сознательное расширение схемы.

11. **Аналитика (раздел 22 ТЗ) реализуется на клиенте**, backend не
    дублирует её отдельным слоем — см. `docs/analytics.md` для полного
    обоснования и двух событий (`issue_solved`, `quiz_completed`), где
    backend всё же возвращает нужные параметры в ответе функции.

12. **Audit-логирование (раздел 21 ТЗ)** — критические действия
    (удаление аккаунта, блокировки) дополнительно пишутся в коллекцию
    `audit_logs` (см. `utils/audit-log.ts`), сверх стандартного
    `firebase-functions/logger`, чтобы у административной панели был
    запрашиваемый журнал, а не только Cloud Logging.

## Что осталось сделать (не входит в этот этап)

- **Покупки/подписки** (раздел 20 ТЗ, коллекция `subscriptions`) — нужна
  интеграция с Google Play Billing / App Store StoreKit через
  RevenueCat или аналог; серверная валидация чеков (webhook) не
  реализована в этом проходе — модель данных (`types/misc.ts`) готова,
  но сами callable/webhook-функции для верификации покупки нет.
- **Реальная компиляция** — см. предупреждение в начале файла, нужен
  `npm install && npm run build` в среде с интернетом.
- **Unit и интеграционные тесты** — `jest`/`firebase-functions-test`
  заданы в `package.json`, но тестовые файлы не написаны в этом проходе.
- **Storage-триггер на удаление аватара** при `deleteAccount` —
  упомянут в комментарии файла, но сам триггер не реализован.
