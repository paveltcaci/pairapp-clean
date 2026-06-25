# PairApp Agent Instructions

Project: PairApp mobile application.

## Main rules

- Do not rewrite the whole project.
- Make minimal, high-confidence changes.
- Do not change architecture unless explicitly asked.
- Do not touch secrets, API keys, .env files, Firebase service account files.
- Do not push to GitHub.
- Do not deploy Firebase.
- Do not modify billing, project settings, or production data.
- Before editing, inspect the relevant files.
- After editing, explain what changed and how to test it.

## Project structure

Mobile app:
- pairapp_mobile/lib/

Backend:
- pairapp-backend/functions/
- firestore.rules
- firestore.indexes.json

## Flutter rules

- Keep existing dark visual style.
- Reuse existing shared widgets, colors, services and models when possible.
- Run or suggest:
  - flutter analyze
  - flutter test

## Firebase rules

- Do not weaken Firestore security rules.
- Do not change collection structure without explaining why.
- Run or suggest:
  - npm run build
  - firebase emulators:start
  - firebase functions:log

## Git workflow

- Work directly on main.
- Do not create branches unless the user explicitly asks.
- Never push automatically.
- Never commit automatically.
- User manually reviews, commits and pushes changes.

## Review guidelines

Check for:
- broken imports
- async bugs
- Firebase permission problems
- Firestore path mistakes
- broken auth / couple / issues / agreements flow
- unnecessary large refactors

## Product specification

The main product specification is:
- TZ_PairApp_v1.docx
- TZ_PairApp_v1.txt

When reviewing or changing the project, always compare the current implementation against the specification.

For every feature, classify status as:
- DONE
- PARTIAL
- MISSING
- BROKEN
- UNCLEAR

Do not invent features outside the specification unless the user explicitly asks.