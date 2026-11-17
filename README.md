# Constropedia — Construction Education Platform

Constropedia is a modern Flutter application designed for civil engineering students, construction professionals, and site practitioners. It provides a structured encyclopedia of construction topics, interactive quizzes with performance analytics, dynamic terms of the day, bookmarks, and a concrete mixture dataset viewer.

---

## 1. Technologies & Architecture

- **Framework**: Flutter 3.x / Dart (Cross-platform: Android, Chrome/Web)
- **Authentication**: Firebase Authentication (Email & Password with session preservation)
- **Database**: Cloud Firestore (Articles, Quizzes, Mixture Data, User Profiles, Bookmarks)
- **Storage**: Firebase Storage (Article imagery)
- **Styling**: Construction-themed custom design system (`AppTheme` & `AppColors`) featuring warm orange accents and high-contrast charcoal typography.

### Project Layout
```text
lib/
├── firebase_options.dart      # Platform Firebase configuration
├── main.dart                  # App bootstrap and AuthGate navigation
├── models/
│   ├── article.dart           # Encyclopedia article model
│   ├── mixture_record.dart    # Concrete mixture dataset record model
│   └── quiz_question.dart     # Quiz question model with difficulty & explanations
├── screens/
│   ├── article_page.dart      # Full article details with dynamic bookmarking
│   ├── bookmarks_page.dart    # Saved articles with swipe-to-delete
│   ├── category_page.dart     # Articles filtered by category
│   ├── cement_mixture_data_page.dart # Paginated concrete mix database viewer
│   ├── component_detail_page.dart    # Concrete component specification viewer
│   ├── home_page.dart         # Main dashboard with rotating Term of the Day
│   ├── login_page.dart        # Authentication sign-in screen
│   ├── signup_page.dart       # Authentication account creation screen
│   ├── quiz_page.dart         # Interactive 10-question category quiz
│   ├── quiz_history_page.dart # Learning progress, analytics & attempt history
│   └── search_page.dart       # Live multi-field encyclopedia search
├── services/
│   ├── firestore_service.dart # Cloud Firestore integration layer
│   └── local_quiz_data.dart   # Verified 50-question fallback question bank
├── theme/
│   └── app_theme.dart         # Global color palette and Material 3 theme
└── widgets/
    ├── app_ui.dart            # Unified UI components (states, chips, headers)
    └── category_card.dart     # Category navigation cards
```

---

## 2. Main Features

1. **Encyclopedia & Categories**:
   - 5 core construction categories:
     - *Materials*
     - *Structural*
     - *Finishing*
     - *Site Safety*
     - *Tools & Machinery*
   - Real-time search across titles, descriptions, content, and categories.

2. **Term of the Day**:
   - Rotates daily based on day-of-the-year hashing from the article catalog.
   - Preserves user context and directly navigates to the detailed article.

3. **Construction Quizzes & Learning Progress**:
   - 10 randomized questions per category (50 curated questions in total).
   - Supports difficulty indicators and individual option explanations.
   - Complete assessment flow: Category Selection → Questions → Scoring → Results → Cloud History.
   - **Learning Progress Dashboard**: Real-time analytics tracking total quizzes completed, overall average score, best score, category-by-category mastery bars, and weak category improvement recommendations.

4. **Concrete Mixture Dataset Viewer**:
   - Dynamic exploration of 1,030 lab test concrete mix records from `articles/cement/mixtureData`.
   - Cursor-based pagination (20 records per batch) with interactive sorting by compressive strength or curing age.
   - Component details breakdown for cement, fly ash, slag, water, aggregates, and superplasticizer.

5. **Personal Bookmarks**:
   - Cloud-persisted per authenticated user under `users/{uid}/bookmarks`.
   - Real-time synchronized state on article detail pages.

---

## 3. Firestore Collections & Security Rules

### Firestore Collections Structure
- `users/{userId}`: Stores user profile information (`name`, `email`, `createdAt`).
  - `users/{userId}/bookmarks/{bookmarkId}`: Saved articles for quick access.
  - `users/{userId}/quizHistory/{attemptId}`: Stored quiz results (`score`, `totalQuestions`, `percentage`, `category`, `completedAt`).
- `articles/{articleId}`: Educational articles (`title`, `description`, `content`, `category`, `imageUrl`, `createdAt`).
  - `articles/cement/mixtureData/{recordId}`: Concrete mixture lab records (`record001` to `record1030`).
- `quizQuestions/{questionId}`: Remote question bank documents (`question`, `options`, `correctAnswer`, `category`, `difficulty`, `optionExplanations`).

### Security Rules Summary
- Client writes to `articles`, `mixtureData`, and `quizQuestions` are disabled (`allow write: if false;`) to protect core curriculum data.
- Read operations on public educational content are open (`allow read: if true;`).
- User profile, bookmarks, and quiz history are strictly protected by UID matching (`request.auth.uid == userId`).

---

## 4. Getting Started & Development

### Prerequisites
- Flutter SDK (3.24+ recommended)
- Android Studio / Android SDK 34+ (for Android builds)
- Google Chrome (for web testing)

### Installation
```bash
# Clone the repository and navigate into the project
git clone <repository-url>
cd constropedia

# Install Flutter dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run the test suite
flutter test

# Run development build in Chrome
flutter run -d chrome
```

---

## 5. Automated Tests
Constropedia includes comprehensive unit and widget tests located in `test/widget_test.dart`:
- `Article` model JSON parsing, optional field fallback, and serialization.
- `ConcreteMixtureRecord` numeric parsing and 9-component property synthesis.
- `QuizQuestionModel` difficulty and explanation validation.
- `LocalQuizData` integrity check (verifying 50 total questions, 10 per category, valid 4-option answers).
- Quiz scoring calculation and edge-case handling.
- UI widget smoke tests (`CategoryCard`, `AppSectionHeader`, `CategoryChip`).
