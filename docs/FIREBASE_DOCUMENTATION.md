# Constropedia — Firebase Backend & Database Documentation

## 1. Overview & Architecture

Constropedia uses Firebase as its cloud backend to provide seamless, real-time access to construction encyclopedia articles, user profiles, persistent bookmarks, and quizzes.

```text
Existing Constropedia Flutter App
             ↓
     Preserved UI & Navigation
             ↓
   FirestoreService Layer (lib/services/firestore_service.dart)
             ↓
   Cloud Firestore + Firebase Auth + Firebase Storage
```

---

## 2. Firebase Services Used

1. **Firebase Authentication**: Email & password authentication with secure session handling.
2. **Cloud Firestore**: NoSQL cloud database storing user profiles, encyclopedia articles, quiz questions, and user bookmarks.
3. **Firebase Storage**: Object storage for article and construction imagery with public download URLs referenced in Firestore.

---

## 3. Final Firestore Database Schema

```text
Firestore
│
├── users
│    └── {userId}
│         ├── name: String
│         ├── email: String
│         ├── createdAt: Timestamp
│         │
│         └── bookmarks
│              └── {bookmarkId}
│                   ├── articleId: String
│                   ├── title: String
│                   ├── description: String
│                   ├── content: String (optional/cached)
│                   ├── category: String
│                   ├── imageUrl: String?
│                   └── createdAt: Timestamp
│
├── articles
│    └── {articleId}
│         ├── title: String
│         ├── description: String
│         ├── content: String
│         ├── category: String
│         ├── imageUrl: String?
│         ├── createdAt: Timestamp
│         │
│         └── mixtureData (subcollection, e.g. for articleId == 'cement')
│              └── {recordId} (record001 ... record1030)
│                   ├── recordId: String
│                   ├── cement: double (kg/m³)
│                   ├── blastFurnaceSlag: double (kg/m³)
│                   ├── flyAsh: double (kg/m³)
│                   ├── water: double (kg/m³)
│                   ├── superplasticizer: double (kg/m³)
│                   ├── coarseAggregate: double (kg/m³)
│                   ├── fineAggregate: double (kg/m³)
│                   ├── age: int (days)
│                   ├── compressiveStrength: double (MPa)
│                   └── createdAt: Timestamp
│
└── quizQuestions
     └── {questionId}
          ├── question: String
          ├── options: List<String>
          ├── correctAnswer: String
          └── category: String
```

### Detailed Field Specifications

#### `users/{userId}`
* `name` (`String`): User's full name.
* `email` (`String`): User's registered email address.
* `createdAt` (`Timestamp`): Server timestamp when the user profile was created.

#### `users/{userId}/bookmarks/{bookmarkId}`
* Document ID (`bookmarkId`): Standardized as the `articleId` (or article title fallback) to prevent duplicate bookmarks.
* `articleId` (`String`): Unique identifier of the bookmarked article.
* `title` (`String`): Title of the article.
* `description` (`String`): Summary or subtitle of the article.
* `content` (`String`): Full content of the article.
* `category` (`String`): Construction category.
* `imageUrl` (`String?`): Optional URL of the article image.
* `createdAt` (`Timestamp`): Server timestamp when the bookmark was added.

#### `articles/{articleId}`
* `title` (`String`): Article title (e.g., "Cement", "Reinforced Concrete").
* `description` (`String`): Concise summary / definition of the topic.
* `content` (`String`): In-depth educational material, applications, and specifications.
* `category` (`String`): Primary topic category (`Materials`, `Structural`, `Finishing`, `Site Safety`, `Tools & Machinery`).
* `imageUrl` (`String?`): Direct HTTP/HTTPS or Storage URL to the article image.
* `createdAt` (`Timestamp`): Server timestamp when the article was created.

#### `quizQuestions/{questionId}`
* `question` (`String`): The question text.
* `options` (`List<String>`): Array of 4 selectable answer choices.
* `correctAnswer` (`String`): Correct answer text or option index matching one of the options.
* `category` (`String`): Associated construction category.

---

## 4. FirestoreService API Reference

Located in [`lib/services/firestore_service.dart`](file:///c:/Projects/constropedia/lib/services/firestore_service.dart).

### User Profile & Auth
* `Future<void> createUserProfile({required String name, required String email})`
  Creates a document under `users/{currentUser.uid}` with name, email, and server timestamp.
* `Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile()`
  Fetches the profile document of the currently authenticated user.
* `Future<void> signOut()`
  Signs out the current user via `FirebaseAuth.instance.signOut()`.

### Articles
* `Stream<List<Article>> getArticles()`
  Returns a real-time stream of all articles ordered by `createdAt` descending.
* `Stream<List<Article>> getArticlesByCategory(String category)`
  Returns a real-time stream of articles matching `where('category', isEqualTo: category)`.
* `Future<Article?> getArticle(String articleId)`
  Retrieves a single article document by its ID from `articles/{articleId}`.

### Bookmarks
* `Future<void> addBookmark({String? articleId, required String title, required String description, required String content, required String category, String? imageUrl})`
  Stores a bookmark under `users/{currentUser.uid}/bookmarks/{articleId}`. Prevents duplicate bookmarks.
* `Future<void> removeBookmark({String? articleId, required String title})`
  Removes the bookmark document from `users/{currentUser.uid}/bookmarks`.
* `Future<bool> isBookmarked({String? articleId, required String title})`
  Checks whether the article is currently bookmarked by the authenticated user.
* `Stream<List<Map<String, dynamic>>> getBookmarks()`
  Streams the current user's bookmarks ordered by `createdAt` descending.

### Quizzes
* `Stream<List<QuizQuestionModel>> getQuizQuestionsByCategory(String category)`
  Streams quiz questions from `quizQuestions` where `category == category`.
* `Future<List<QuizQuestionModel>> fetchQuizQuestions(String category)`
  Fetches quiz questions for a category from Firestore with graceful fallback to local data.

### Data Seeding Helper
* `Future<void> seedInitialDataIfNeeded()`
  Checks if `articles` collection is empty; if so, populates initial high-quality articles across all five construction categories.

---

## 5. Security Rules

### Firestore Security ([`firestore.rules`](file:///c:/Projects/constropedia/firestore.rules))
* **Private User Data (`users/{userId}` and `users/{userId}/bookmarks/{bookmarkId}`)**:
  Enforces `request.auth != null && request.auth.uid == userId`. Users cannot read or write another user's profile or bookmarks. Unauthenticated requests are completely blocked.
* **Articles (`articles/{articleId}`)**:
  `allow read: if true;` (public read-only). Normal clients cannot write (`allow write: if false;`).
* **Quiz Questions (`quizQuestions/{questionId}`)**:
  `allow read: if true;` (public read-only). Normal clients cannot tamper with quiz questions (`allow write: if false;`).
* **Default**:
  All other document paths are denied (`allow read, write: if false;`).

### Storage Security ([`storage.rules`](file:///c:/Projects/constropedia/storage.rules))
* `article_images/{image}`: Publicly readable; client writes require authenticated authorization.
* `users/{userId}/**`: Accessible only by the owner user (`request.auth.uid == userId`).

---

## 6. Image Strategy

The field name is strictly standardized as:
```text
imageUrl
```
Image URLs are direct HTTPS links (hosted either on Firebase Storage or verified CDN assets). When loading in Flutter, `ArticlePage` utilizes caching and graceful fallback handling with loading placeholders and error states.
