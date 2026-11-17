# Firestore Quiz Questions Seeder

This script seeds the 50 verified quiz questions into Firestore (`quizQuestions` collection).

## Prerequisites

1. Node.js installed (v18+)
2. Firebase Admin SDK service account key (JSON)

## Setup

```bash
cd tools/seed_quiz_questions
npm install
```

## Get Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project `constropedia-7d7a3`
3. Settings → Service Accounts → Generate new private key
4. Save the downloaded JSON as `serviceAccountKey.json` in this folder

> **IMPORTANT:** Never commit `serviceAccountKey.json` to git.

## Run

```bash
node seed.js
```

The script is **idempotent** — it uses `doc.set()` with the question `id` as the document ID.
Running it again will overwrite existing documents with the same data (safe to re-run).

## What it seeds

- **50 questions** across 5 categories:
  - Materials (10)
  - Structural (10)
  - Finishing (10)
  - Site Safety (10)
  - Tools & Machinery (10)
- Each question has: `id`, `question`, `options[]`, `correctAnswer`, `category`, `difficulty`, `optionExplanations{}`

## After seeding

The app's `fetchQuizQuestions()` checks Firestore first. With 10+ questions per category in Firestore, it will use remote data and skip the local fallback.

