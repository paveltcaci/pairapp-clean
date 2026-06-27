# PairApp Agent Instructions

Project: PairApp mobile application.

Repository root is usually:

`F:\LOVEAPP\app1.0`

## Communication

* Reply to the user in Russian unless the user explicitly asks for another language.
* Be direct, practical, and specific.
* Prefer exact file paths, exact commands, and copy-paste-ready code.
* Do not give vague advice.
* If information is missing, ask for the smallest necessary file, snippet, log, or command output.

## Main rules

* Do not rewrite the whole project.
* Make minimal, high-confidence changes.
* Do not change architecture unless explicitly asked.
* Do not rename models, services, routes, Firestore collections, Firestore fields, Firebase Functions, or public APIs unless necessary.
* Do not touch secrets, API keys, `.env` files, Firebase service account files, billing, project settings, or production data.
* Do not push to GitHub.
* Do not deploy Firebase.
* Do not commit automatically.
* User manually reviews, commits, and pushes changes.
* Before editing, inspect the relevant files.
* Do not invent file contents. If exact current contents are needed, read the file first.
* After editing, explain what changed and how to test it.

## Default workflow

For every coding task, follow this order:

1. Inspect relevant files.
2. Explain the current flow.
3. Identify the exact likely cause of the issue.
4. Propose the smallest safe fix.
5. Change only the necessary files.
6. Show changed files.
7. Show or summarize the diff.
8. Provide exact Windows commands to test.
9. Mention any command that could not be run.

If the user says "диагностика без правок", do not edit files.

If the user says "сначала только анализ", do not edit files.

## Project structure

Mobile app:

* `pairapp_mobile/lib/`

Backend:

* `pairapp-backend/functions/`
* `firestore.rules`
* `firestore.indexes.json`

Main expected areas:

* Auth flow
* User profile flow
* Couple flow
* Issues flow
* Agreements flow
* Chat flow
* Firebase services
* Firestore rules and indexes

## Flutter rules

* Keep the existing dark visual style.
* Reuse existing shared widgets, colors, services, and models when possible.
* Prefer existing services instead of calling Firebase directly from screens.
* Keep screens focused on UI/state.
* Keep services focused on Firebase/business logic.
* Handle loading, empty, error, and success states.
* Avoid full-screen spinners if previous/cached data can still be shown.
* Avoid `setState` after dispose.
* Use `mounted` checks after async operations.
* Be careful with `StreamBuilder` lifecycle.
* Avoid duplicate streams and unnecessary nested `StreamBuilder`s.
* Do not introduce new dependencies without asking.

Suggested checks:

```bash
cd pairapp_mobile
flutter analyze
flutter test
```

## Firebase / Firestore rules

* Do not weaken Firestore security rules.
* Do not change collection structure without explaining why.
* Validate document existence before reading fields.
* Keep Firestore field names consistent with existing models.
* Use transactions or batched writes when related documents must stay consistent.
* Be careful with stream lifecycles and Firestore subscriptions.
* Avoid permission-breaking changes.
* Avoid writing to production data unless the user explicitly asks and confirms.

Suggested checks:

```bash
cd pairapp-backend/functions
npm run build
npm test
npm run lint
```

Other useful commands:

```bash
firebase emulators:start
firebase functions:log
```

## Backend rules

* Backend is Firebase Cloud Functions with TypeScript.
* Inspect existing exports and module structure before editing.
* Preserve existing callable/function names.
* Do not change API contracts unless explicitly requested.
* Prefer small fixes with clear validation.
* Do not deploy functions automatically.

## Git workflow

* Work directly on `main` unless the user explicitly asks to create a branch.
* Before changes, check:

```bash
git status
```

* Do not overwrite unrelated local changes.
* Do not commit unless the user explicitly asks.
* Do not push unless the user explicitly asks.
* If a patch does not apply, do not force it. Inspect the current file and provide a manual safe edit.

## Patch rules

When changing code:

* Prefer small patches.
* Do not do unrelated formatting.
* Do not refactor unrelated files.
* If using unified diff, make sure it matches the current file.
* If exact patch context is uncertain, provide manual replacement blocks with exact search text.
* Explain why each changed file was needed.

## Review guidelines

Check for:

* broken imports
* null-safety issues
* async bugs
* `setState` after dispose
* Firebase permission problems
* Firestore path mistakes
* broken auth / couple / issues / agreements / chat flow
* incorrect stream lifecycle
* unnecessary large refactors
* UI loading states that can cause stuck spinners
* model-field mismatches between Dart, Firestore, and backend functions

## Product specification

The main product specification is:

* `TZ_PairApp_v1.docx`
* `TZ_PairApp_v1.txt`

When reviewing or changing the project, compare the current implementation against the specification when those files are available.

For every feature, classify status as:

* DONE
* PARTIAL
* MISSING
* BROKEN
* UNCLEAR

Do not invent features outside the specification unless the user explicitly asks.

## Definition of done

A task is done only when:

* the minimal fix is implemented;
* changed files are listed;
* the reason for the change is explained;
* possible risks are mentioned;
* test/check commands are provided;
* the user can manually review before commit/push.

## Command working directories

The repository root is:

`F:\LOVEAPP\app1.0`

Do not run Flutter commands from the repository root.

Flutter commands must be run from:

`F:\LOVEAPP\app1.0\pairapp_mobile`

Correct Flutter command sequence on Windows PowerShell:

```powershell
Set-Location F:\LOVEAPP\app1.0\pairapp_mobile
flutter pub get
flutter analyze
flutter test