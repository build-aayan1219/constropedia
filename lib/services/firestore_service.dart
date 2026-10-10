import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../models/mixture_record.dart';
import '../models/quiz_question.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================================================
  // USER PROFILE
  // ==================================================

  Future<void> createUserProfile({
    required String name,
    required String email,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return await _firestore.collection('users').doc(user.uid).get();
  }

  // ==================================================
  // INITIAL DATA CHECK
  // ==================================================

  Future<void> seedInitialDataIfNeeded() async {
    try {
      final articlesSnapshot = await _firestore
          .collection('articles')
          .limit(1)
          .get();

      if (articlesSnapshot.docs.isNotEmpty) {
        return;
      }

      debugPrint(
        'No articles found in Firestore. '
        'Initial article data has not been seeded.',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'Error checking initial article data: '
        '${e.code} - ${e.message}',
      );
    } catch (e) {
      debugPrint('Error checking initial article data: $e');
    }
  }

  // ==================================================
  // ARTICLES
  // ==================================================

  Future<List<Article>> getArticles() async {
    final snapshot = await _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Article.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<Article>> getArticlesByCategory(String category) async {
    final snapshot = await _firestore
        .collection('articles')
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs
        .map((doc) => Article.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<Article?> getArticleById(String articleId) async {
    final document = await _firestore
        .collection('articles')
        .doc(articleId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return Article.fromMap(document.id, document.data()!);
  }

  // ==================================================
  // SEARCH
  // ==================================================

  Future<List<Article>> searchArticles(String searchText) async {
    final query = searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return [];
    }

    final snapshot = await _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Article.fromMap(doc.id, doc.data()))
        .where(
          (article) =>
              article.title.toLowerCase().contains(query) ||
              article.description.toLowerCase().contains(query) ||
              article.content.toLowerCase().contains(query) ||
              article.category.toLowerCase().contains(query),
        )
        .toList();
  }

  // ==================================================
  // BOOKMARKS
  // ==================================================

  Future<void> addBookmark({
    String? articleId,
    required String title,
    required String description,
    String content = '',
    String category = '',
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(title)
        .set({
          'title': title,
          'description': description,
          'content': content,
          'category': category,
          'imageUrl': imageUrl ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> removeBookmark({
    String? articleId,
    required String title,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(title)
        .delete();
  }

  Future<bool> isBookmarked({String? articleId, required String title}) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final document = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(title)
        .get();

    return document.exists;
  }

  Stream<List<Map<String, dynamic>>> getBookmarks() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // ==================================================
  // CONCRETE MIXTURE DATA
  // ==================================================

  Future<ConcreteMixtureRecord?> getSampleMixtureRecord({
    String articleId = 'cement',
  }) async {
    final snapshot = await _firestore
        .collection('articles')
        .doc(articleId)
        .collection('mixtureData')
        .doc('record001')
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return ConcreteMixtureRecord.fromMap(snapshot.id, snapshot.data()!);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMixtureDataSnapshot({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String articleId = 'cement',
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('articles')
        .doc(articleId)
        .collection('mixtureData')
        .orderBy('recordId')
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return await query.get();
  }

  Future<List<ConcreteMixtureRecord>> getCementMixtureData({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String articleId = 'cement',
  }) async {
    final snapshot = await getMixtureDataSnapshot(
      articleId: articleId,
      limit: limit,
      startAfter: startAfter,
    );

    return snapshot.docs
        .map((doc) => ConcreteMixtureRecord.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ==================================================
  // QUIZ QUESTIONS
  // ==================================================

  Future<List<QuizQuestionModel>> fetchQuizQuestions(
  String category,
) async {
  try {
    final snapshot = await _firestore
        .collection('quizQuestions')
        .where(
          'category',
          isEqualTo: category,
        )
        .get();

    final questions = snapshot.docs
        .map(
          (doc) => QuizQuestionModel.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();

    questions.shuffle();

    // The quiz requires 10 questions.  
    if (questions.length < 10) {
      debugPrint(
        'Only ${questions.length} quiz questions found '
        'for category: $category',
      );
    }

    return questions.take(10).toList();
  } on FirebaseException catch (e) {
    debugPrint(
      'Quiz question loading error: '
      '${e.code} - ${e.message}',
    );

    rethrow;
  } catch (e) {
    debugPrint(
      'Quiz question loading error: $e',
    );
    rethrow;
  }
}

  // ==================================================
  // QUIZ HISTORY
  // ==================================================

  Future<void> saveQuizResult({
    required String category,
    required int score,
    required int totalQuestions,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('quizHistory')
        .add({
          'category': category,
          'score': score,
          'totalQuestions': totalQuestions,
          'percentage': totalQuestions == 0
              ? 0
              : ((score / totalQuestions) * 100).round(),
          'completedAt': FieldValue.serverTimestamp(),
        });
  }

  Stream<List<Map<String, dynamic>>> getQuizHistory() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('quizHistory')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }
}
