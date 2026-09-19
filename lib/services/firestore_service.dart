import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../models/quiz_question.dart';
import '../models/mixture_record.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --------------------------------------------------
  // AUTHENTICATION & SESSION
  // --------------------------------------------------

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --------------------------------------------------
  // USER PROFILE
  // --------------------------------------------------

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

    return await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
  }

  // --------------------------------------------------
  // ARTICLES
  // --------------------------------------------------

  /// Get all articles from Firestore.
  Stream<List<Article>> getArticles() {
    return _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Article.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  /// Get articles belonging to a particular category.
  Stream<List<Article>> getArticlesByCategory(
    String category,
  ) {
    return _firestore
        .collection('articles')
        .where(
          'category',
          isEqualTo: category,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Article.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  /// Get a single article by ID.
  Future<Article?> getArticle(
    String articleId,
  ) async {
    try {
      final doc = await _firestore
          .collection('articles')
          .doc(articleId)
          .get();

      if (doc.exists && doc.data() != null) {
        return Article.fromMap(
          doc.id,
          doc.data()!,
        );
      }

      return null;
    } catch (e) {
      debugPrint(
        'Error getting article $articleId: $e',
      );
      return null;
    }
  }

  // --------------------------------------------------
  // BOOKMARKS
  // --------------------------------------------------

  Future<void> addBookmark({
    String? articleId,
    required String title,
    required String description,
    required String content,
    required String category,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    // Prefer articleId as document ID.
    // This prevents duplicate bookmarks for
    // the same Firestore article.
    final bookmarkId =
        (articleId != null && articleId.trim().isNotEmpty)
            ? articleId.trim()
            : title;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(bookmarkId)
        .set({
      'articleId': bookmarkId,
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
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

    final docId =
        (articleId != null && articleId.trim().isNotEmpty)
            ? articleId.trim()
            : title;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(docId)
        .delete();

    // If the current document uses articleId and
    // an older bookmark used title as its ID,
    // remove that old document too.
    if (docId != title) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .doc(title)
          .delete()
          .catchError((_) {});
    }
  }

  Future<bool> isBookmarked({
    String? articleId,
    required String title,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final docId =
        (articleId != null && articleId.trim().isNotEmpty)
            ? articleId.trim()
            : title;

    final document = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(docId)
        .get();

    if (document.exists) {
      return true;
    }

    // Check title-based bookmark as a fallback.
    if (docId != title) {
      final titleDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .doc(title)
          .get();

      return titleDoc.exists;
    }

    return false;
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
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => {
                  'id': doc.id,
                  'articleId':
                      doc.data()['articleId'] ?? doc.id,
                  ...doc.data(),
                },
              )
              .toList(),
        );
  }

  // --------------------------------------------------
  // QUIZ QUESTIONS
  // --------------------------------------------------

  /// Get quiz questions for a category from Firestore.
  Stream<List<QuizQuestionModel>> getQuizQuestionsByCategory(
    String category,
  ) {
    return _firestore
        .collection('quizQuestions')
        .where(
          'category',
          isEqualTo: category,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => QuizQuestionModel.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  /// Get quiz questions for a category once.
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

      return snapshot.docs
          .map(
            (doc) => QuizQuestionModel.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint(
        'Error fetching quiz questions: $e',
      );

      return [];
    }
  }

  // --------------------------------------------------
  // QUIZ HISTORY
  // --------------------------------------------------

  /// Save one completed quiz attempt for the
  /// currently authenticated user.
  Future<void> saveQuizResult({
    required String category,
    required int score,
    required int totalQuestions,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    if (totalQuestions <= 0) {
      throw Exception(
        'Total questions must be greater than zero',
      );
    }

    if (score < 0 || score > totalQuestions) {
      throw Exception(
        'Invalid quiz score',
      );
    }

    final percentage =
        (score / totalQuestions) * 100;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('quizHistory')
        .add({
      'category': category,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get the quiz history of the currently
  /// authenticated user.
  Stream<List<Map<String, dynamic>>> getQuizHistory() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('quizHistory')
        .orderBy(
          'completedAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => {
                  'id': doc.id,
                  ...doc.data(),
                },
              )
              .toList(),
        );
  }

  // --------------------------------------------------
  // CONCRETE MIXTURE DATA
  // --------------------------------------------------

  /// Get sample mixture record
  /// for previewing component values.
  Future<ConcreteMixtureRecord?> getSampleMixtureRecord({
    String articleId = 'cement',
  }) async {
    try {
      // First try record001 directly.
      final doc = await _firestore
          .collection('articles')
          .doc(articleId)
          .collection('mixtureData')
          .doc('record001')
          .get();

      if (doc.exists && doc.data() != null) {
        return ConcreteMixtureRecord.fromMap(
          doc.id,
          doc.data()!,
        );
      }

      // Fallback: get first available document.
      final querySnap = await _firestore
          .collection('articles')
          .doc(articleId)
          .collection('mixtureData')
          .limit(1)
          .get();

      if (querySnap.docs.isNotEmpty) {
        final firstDoc = querySnap.docs.first;

        return ConcreteMixtureRecord.fromMap(
          firstDoc.id,
          firstDoc.data(),
        );
      }

      return null;
    } catch (e) {
      debugPrint(
        'Error getting sample mixture record for '
        '$articleId: $e',
      );

      return null;
    }
  }

  /// Get paginated mixture records.
  Future<List<ConcreteMixtureRecord>> getCementMixtureData({
    String articleId = 'cement',
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore
              .collection('articles')
              .doc(articleId)
              .collection('mixtureData')
              .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(
          startAfter,
        );
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => ConcreteMixtureRecord.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint(
        'Error getting mixture records for '
        '$articleId: $e',
      );

      return [];
    }
  }

  /// Get query snapshot for paginated browsing.
  Future<QuerySnapshot<Map<String, dynamic>>>
      getMixtureDataSnapshot({
    String articleId = 'cement',
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore
            .collection('articles')
            .doc(articleId)
            .collection('mixtureData')
            .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(
        startAfter,
      );
    }

    return await query.get();
  }

  // --------------------------------------------------
  // DATA SEEDING HELPER
  // --------------------------------------------------

  Future<void> seedInitialDataIfNeeded() async {
    try {
      final articlesSnapshot = await _firestore
          .collection('articles')
          .limit(1)
          .get();

      if (articlesSnapshot.docs.isEmpty) {
        final initialArticles = [
          {
            'title': 'Cement',
            'description':
                'A hydraulic binder substance that sets, hardens, and adheres to other materials to bind them together.',
            'content':
                'Cement is a fine powder made from limestone, clay, and gypsum. When mixed with water, sand, and gravel, it forms concrete or mortar. Portland cement is the most common type used worldwide.',
            'category': 'Materials',
            'imageUrl':
                'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=800&auto=format&fit=crop',
            'createdAt':
                FieldValue.serverTimestamp(),
          },
          {
            'title': 'Concrete',
            'description':
                'A composite construction material composed of fine and coarse aggregate bonded together with fluid cement that hardens over time.',
            'content':
                'Concrete is the most widely used man-made material in existence. It has immense compressive strength and is widely reinforced with steel rebar to form Reinforced Cement Concrete (RCC).',
            'category': 'Materials',
            'imageUrl':
                'https://images.unsplash.com/photo-1541888946425-d0fbb186c5f8?w=800&auto=format&fit=crop',
            'createdAt':
                FieldValue.serverTimestamp(),
          },
          {
            'title': 'Bricks',
            'description':
                'Rectangular masonry units made of clay, shale, or concrete used for building walls and pavements.',
            'content':
                'Standard burnt clay bricks provide excellent thermal insulation, fire resistance, and structural durability. Modern alternatives include fly-ash bricks and autoclaved aerated concrete (AAC) blocks.',
            'category': 'Materials',
            'imageUrl':
                'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=800&auto=format&fit=crop',
            'createdAt':
                FieldValue.serverTimestamp(),
          },
          {
            'title': 'Steel Reinforcement',
            'description':
                'High-tensile steel bars (rebar) embedded in concrete to carry tensile loads and prevent cracking.',
            'content':
                'While concrete excels in compression, its tensile strength is only about 10% of compressive strength. Thermo-Mechanically Treated (TMT) steel rebars bond with concrete to withstand dynamic tensile and shear stresses.',
            'category': 'Materials',
            'imageUrl':
                'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=800&auto=format&fit=crop',
            'createdAt':
                FieldValue.serverTimestamp(),
          },
          {
            'title': 'Foundations',
            'description':
                'The lowest part of a building structure that safely transfers superstructure loads down into the underlying soil or rock.',
            'content':
                'Foundations are classified into shallow foundations (pad footings, strip footings, raft/mat foundations) and deep foundations (pile foundations, caissons). Soil bearing capacity dictates foundation type.',
            'category': 'Structural',
            'imageUrl':
                'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=800&auto=format&fit=crop',
            'createdAt':
                FieldValue.serverTimestamp(),
          },
          {
            'title': 'Beams & Slabs',
            'description':
                'Horizontal structural members that carry vertical gravity loads and transfer them into vertical columns.',
            'content':
                'Beams resist bending moments and shear stresses. Slabs act as floors or roofs, distributing surface live loads uniformly to the supporting beam grid.',
            'category': 'Structural',
            'imageUrl':
                'https://images.unsplash.com/photo-1517581177682-a085bb7ffb15?w=800&auto=format&fit=crop',
            'createdAt':
                FieldValue.serverTimestamp(),
          },
          {
            'title': 'Plastering & Putty',
            'description':
                'Protective and decorative layer of mortar applied over masonry walls to provide a smooth, durable finish.',
            'content':
                'Cement-sand plaster protects brickwork from rain and weathering. Wall putty fills microscopic voids and provides an ultra-smooth base for paint primers.',
            'category': 'Finishing',
            'imageUrl':
                'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&auto=format&fit=crop',
            'createdAt':
                FieldValue.serverTimestamp(),
          },
          {
            'title': 'Personal Protective Equipment',
            'description':
                'Crucial protective gear required on job sites to protect workers from physical hazards, falls, and injuries.',
            'content':
                'Essential PPE includes hard hats (head protection), steel-toed boots (crush and puncture protection), high-visibility reflective vests, safety goggles, and safety harnesses for working at heights.',
            'category': 'Site Safety',
            'imageUrl':
                'https://images.unsplash.com/photo-1578575437130-527eed3abbec?w=800&auto=format&fit=crop',
            'createdAt':
                FieldValue.serverTimestamp(),
          },
          {
            'title': 'Concrete Mixer & Batching Plant',
            'description':
                'Machinery designed to homogeneously combine cement, aggregate, sand, and water to produce high-grade concrete.',
            'content':
                'From portable tilting-drum mixers to computer-controlled automated ready-mix concrete (RMC) batching plants, continuous and uniform mixing is vital for structural grade specifications.',
            'category': 'Tools & Machinery',
            'imageUrl':
                'https://images.unsplash.com/photo-1581092335397-9583fe92d232?w=800&auto=format&fit=crop',
            'createdAt':
                FieldValue.serverTimestamp(),
          },
        ];

        final batch = _firestore.batch();

        for (final item in initialArticles) {
          final docRef =
              _firestore.collection('articles').doc();

          batch.set(
            docRef,
            item,
          );
        }

        await batch.commit();

        debugPrint(
          'Seeded initial articles into Firestore.',
        );
      }
    } catch (e) {
      debugPrint(
        'Error in seedInitialDataIfNeeded: $e',
      );
    }
  }
}