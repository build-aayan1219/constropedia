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

    return await _firestore.collection('users').doc(user.uid).get();
  }

  // --------------------------------------------------
  // ARTICLES
  // --------------------------------------------------

  /// Get all articles from Firestore
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

  /// Get articles belonging to a particular category as a real-time Stream
  Stream<List<Article>> getArticlesByCategory(String category) {
    return _firestore
        .collection('articles')
        .where('category', isEqualTo: category)
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

  /// Get single article by ID
  Future<Article?> getArticle(String articleId) async {
    try {
      final doc = await _firestore.collection('articles').doc(articleId).get();
      if (doc.exists && doc.data() != null) {
        return Article.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting article $articleId: $e');
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
    String content = '',
    String category = '',
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    // Prefer articleId as docId to prevent duplicate bookmarks for the same article
    final bookmarkId = (articleId != null && articleId.trim().isNotEmpty)
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

    final docId = (articleId != null && articleId.trim().isNotEmpty)
        ? articleId.trim()
        : title;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(docId)
        .delete();

    // If docId was an articleId different from title, also clean up title-keyed doc if it exists
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

    final docId = (articleId != null && articleId.trim().isNotEmpty)
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

    // Check title-keyed fallback if different
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
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => {
                  'id': doc.id,
                  'articleId': doc.data()['articleId'] ?? doc.id,
                  ...doc.data(),
                },
              )
              .toList(),
        );
  }

  // --------------------------------------------------
  // QUIZ QUESTIONS
  // --------------------------------------------------

  /// Get quiz questions for a category from Firestore as a Stream
  Stream<List<QuizQuestionModel>> getQuizQuestionsByCategory(String category) {
    return _firestore
        .collection('quizQuestions')
        .where('category', isEqualTo: category)
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

  /// Get quiz questions for a category (one-time Future) with shuffle
  Future<List<QuizQuestionModel>> fetchQuizQuestions(String category) async {
    try {
      final snapshot = await _firestore
          .collection('quizQuestions')
          .where('category', isEqualTo: category)
          .get();

      final questions = snapshot.docs.map((doc) {
        return QuizQuestionModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();

      if (questions.isEmpty) {
        // Fallback to local question bank if firestore has not seeded this category yet
        final localQuestions = _quizQuestionBank()
            .where((q) => q.category.toLowerCase() == category.toLowerCase())
            .toList();
        localQuestions.shuffle();
        return localQuestions.take(10).toList();
      }

      questions.shuffle();
      return questions.take(10).toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore error fetching quiz questions: ${e.message}');
      final localQuestions = _quizQuestionBank()
          .where((q) => q.category.toLowerCase() == category.toLowerCase())
          .toList();
      localQuestions.shuffle();
      return localQuestions.take(10).toList();
    } catch (e) {
      debugPrint('Error fetching quiz questions: $e');
      final localQuestions = _quizQuestionBank()
          .where((q) => q.category.toLowerCase() == category.toLowerCase())
          .toList();
      localQuestions.shuffle();
      return localQuestions.take(10).toList();
    }
  }

  // --------------------------------------------------
  // CONCRETE MIXTURE DATA
  // --------------------------------------------------

  /// Get sample mixture record (e.g. record001) for previewing component values
  Future<ConcreteMixtureRecord?> getSampleMixtureRecord({
    String articleId = 'cement',
  }) async {
    try {
      // First try record001 directly
      final doc = await _firestore
          .collection('articles')
          .doc(articleId)
          .collection('mixtureData')
          .doc('record001')
          .get();

      if (doc.exists && doc.data() != null) {
        return ConcreteMixtureRecord.fromMap(doc.id, doc.data()!);
      }

      // Fallback: get first available document
      final querySnap = await _firestore
          .collection('articles')
          .doc(articleId)
          .collection('mixtureData')
          .limit(1)
          .get();

      if (querySnap.docs.isNotEmpty) {
        final firstDoc = querySnap.docs.first;
        return ConcreteMixtureRecord.fromMap(firstDoc.id, firstDoc.data());
      }

      // Default sample fallback so the UI always has realistic technical data
      return ConcreteMixtureRecord(
        id: 'record001',
        cement: 540.0,
        blastFurnaceSlag: 0.0,
        flyAsh: 0.0,
        water: 162.0,
        superplasticizer: 2.5,
        coarseAggregate: 1040.0,
        fineAggregate: 676.0,
        age: 28,
        compressiveStrength: 79.99,
      );
    } catch (e) {
      debugPrint('Error getting sample mixture record for $articleId: $e');
      return ConcreteMixtureRecord(
        id: 'record001',
        cement: 540.0,
        blastFurnaceSlag: 0.0,
        flyAsh: 0.0,
        water: 162.0,
        superplasticizer: 2.5,
        coarseAggregate: 1040.0,
        fineAggregate: 676.0,
        age: 28,
        compressiveStrength: 79.99,
      );
    }
  }

  /// Get paginated mixture records from articles/{articleId}/mixtureData
  Future<List<ConcreteMixtureRecord>> getCementMixtureData({
    String articleId = 'cement',
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('articles')
          .doc(articleId)
          .collection('mixtureData')
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => ConcreteMixtureRecord.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting mixture records for $articleId: $e');
      return [];
    }
  }

  /// Get query snapshot for paginated browsing
  Future<QuerySnapshot<Map<String, dynamic>>> getMixtureDataSnapshot({
    String articleId = 'cement',
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('articles')
        .doc(articleId)
        .collection('mixtureData')
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return await query.get();
  }

  // --------------------------------------------------
  // QUIZ RESULTS / HISTORY
  // --------------------------------------------------

  Future<void> saveQuizResult({
    required String category,
    required int score,
    required int totalQuestions,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final percentage = totalQuestions == 0
        ? 0
        : ((score / totalQuestions) * 100).round();

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
  // SEED QUIZ QUESTIONS
  // --------------------------------------------------

  Future<void> seedQuizQuestions() async {
    final questions = _quizQuestionBank();
    final batch = _firestore.batch();

    for (final question in questions) {
      final document =
          _firestore.collection('quizQuestions').doc(question.id);

      batch.set(
        document,
        question.toMap(),
      );
    }

    await batch.commit();
  }

  List<QuizQuestionModel> _quizQuestionBank() {
    return [
      // MATERIALS - 10
      QuizQuestionModel(
        id: 'materials_01',
        category: 'Materials',
        question: 'Which material is commonly used as a binder in concrete?',
        options: ['Cement', 'Timber', 'Glass', 'Plastic'],
        correctAnswer: 'Cement',
      ),
      QuizQuestionModel(
        id: 'materials_02',
        category: 'Materials',
        question: 'Which material is commonly used for masonry walls?',
        options: ['Brick', 'Rubber', 'Paper', 'Foam'],
        correctAnswer: 'Brick',
      ),
      QuizQuestionModel(
        id: 'materials_03',
        category: 'Materials',
        question: 'Which material is commonly used as reinforcement in concrete?',
        options: ['Steel', 'Cardboard', 'Cloth', 'Glass'],
        correctAnswer: 'Steel',
      ),
      QuizQuestionModel(
        id: 'materials_04',
        category: 'Materials',
        question: 'What is concrete generally made from?',
        options: [
          'Cement, water and aggregates',
          'Wood and glass',
          'Plastic and rubber',
          'Steel and timber only',
        ],
        correctAnswer: 'Cement, water and aggregates',
      ),
      QuizQuestionModel(
        id: 'materials_05',
        category: 'Materials',
        question: 'Which material is commonly used for window glazing?',
        options: ['Glass', 'Concrete', 'Brick', 'Bitumen'],
        correctAnswer: 'Glass',
      ),
      QuizQuestionModel(
        id: 'materials_06',
        category: 'Materials',
        question: 'Which material is commonly used for waterproofing roofs?',
        options: ['Bitumen', 'Brick', 'Timber', 'Sand'],
        correctAnswer: 'Bitumen',
      ),
      QuizQuestionModel(
        id: 'materials_07',
        category: 'Materials',
        question: 'Which natural material is commonly used in traditional construction?',
        options: ['Stone', 'Plastic', 'Nylon', 'Foam'],
        correctAnswer: 'Stone',
      ),
      QuizQuestionModel(
        id: 'materials_08',
        category: 'Materials',
        question: 'What is aggregate used for in concrete?',
        options: [
          'To provide bulk and strength',
          'To provide electrical power',
          'To paint concrete',
          'To replace all cement',
        ],
        correctAnswer: 'To provide bulk and strength',
      ),
      QuizQuestionModel(
        id: 'materials_09',
        category: 'Materials',
        question: 'Which material is commonly used for structural timber framing?',
        options: ['Wood', 'Glass', 'Cement', 'Ceramic'],
        correctAnswer: 'Wood',
      ),
      QuizQuestionModel(
        id: 'materials_10',
        category: 'Materials',
        question: 'Which material is commonly used to make floor tiles?',
        options: ['Ceramic', 'Paper', 'Rubber', 'Timber only'],
        correctAnswer: 'Ceramic',
      ),

      // STRUCTURAL - 10
      QuizQuestionModel(
        id: 'structural_01',
        category: 'Structural',
        question: 'What is the main purpose of a building foundation?',
        options: [
          'Transfer loads to the ground',
          'Decorate the building',
          'Provide lighting',
          'Paint the walls',
        ],
        correctAnswer: 'Transfer loads to the ground',
      ),
      QuizQuestionModel(
        id: 'structural_02',
        category: 'Structural',
        question: 'Which structural member primarily carries loads horizontally?',
        options: ['Beam', 'Column', 'Foundation', 'Wall finish'],
        correctAnswer: 'Beam',
      ),
      QuizQuestionModel(
        id: 'structural_03',
        category: 'Structural',
        question: 'Which structural member primarily carries vertical loads?',
        options: ['Column', 'Beam', 'Tile', 'Ceiling paint'],
        correctAnswer: 'Column',
      ),
      QuizQuestionModel(
        id: 'structural_04',
        category: 'Structural',
        question: 'What does a slab generally provide in a building?',
        options: [
          'A horizontal structural surface',
          'Only wall decoration',
          'Electrical wiring',
          'Water storage',
        ],
        correctAnswer: 'A horizontal structural surface',
      ),
      QuizQuestionModel(
        id: 'structural_05',
        category: 'Structural',
        question: 'What is reinforced concrete?',
        options: [
          'Concrete combined with reinforcement',
          'Concrete without cement',
          'Wood mixed with glass',
          'Brick mixed with paint',
        ],
        correctAnswer: 'Concrete combined with reinforcement',
      ),
      QuizQuestionModel(
        id: 'structural_06',
        category: 'Structural',
        question: 'What is a column mainly designed to resist?',
        options: ['Compression', 'Painting', 'Water absorption only', 'Decoration'],
        correctAnswer: 'Compression',
      ),
      QuizQuestionModel(
        id: 'structural_07',
        category: 'Structural',
        question: 'What connects a building structure to its foundation?',
        options: [
          'Structural support system',
          'Paint coating',
          'Floor tile',
          'Window glass',
        ],
        correctAnswer: 'Structural support system',
      ),
      QuizQuestionModel(
        id: 'structural_08',
        category: 'Structural',
        question: 'Which type of foundation is commonly used for individual columns?',
        options: ['Isolated footing', 'Roof slab', 'Lintel', 'Parapet'],
        correctAnswer: 'Isolated footing',
      ),
      QuizQuestionModel(
        id: 'structural_09',
        category: 'Structural',
        question: 'What is the purpose of structural reinforcement?',
        options: [
          'Improve load-carrying performance',
          'Change wall color',
          'Provide lighting',
          'Seal windows',
        ],
        correctAnswer: 'Improve load-carrying performance',
      ),
      QuizQuestionModel(
        id: 'structural_10',
        category: 'Structural',
        question: 'Which element is commonly used above a door or window opening?',
        options: ['Lintel', 'Foundation', 'Footing', 'Floor tile'],
        correctAnswer: 'Lintel',
      ),

      // FINISHING - 10
      QuizQuestionModel(
        id: 'finishing_01',
        category: 'Finishing',
        question: 'What is plastering mainly used for?',
        options: [
          'Creating a smooth wall surface',
          'Making foundations',
          'Lifting materials',
          'Testing soil',
        ],
        correctAnswer: 'Creating a smooth wall surface',
      ),
      QuizQuestionModel(
        id: 'finishing_02',
        category: 'Finishing',
        question: 'What is the purpose of painting a wall?',
        options: [
          'Protection and appearance',
          'Structural reinforcement',
          'Foundation support',
          'Soil testing',
        ],
        correctAnswer: 'Protection and appearance',
      ),
      QuizQuestionModel(
        id: 'finishing_03',
        category: 'Finishing',
        question: 'Which material is commonly used for floor finishing?',
        options: ['Tiles', 'Rebar', 'Cement bags only', 'Scaffolding'],
        correctAnswer: 'Tiles',
      ),
      QuizQuestionModel(
        id: 'finishing_04',
        category: 'Finishing',
        question: 'What is grouting commonly used for?',
        options: [
          'Filling joints between tiles',
          'Lifting concrete',
          'Testing steel',
          'Building foundations',
        ],
        correctAnswer: 'Filling joints between tiles',
      ),
      QuizQuestionModel(
        id: 'finishing_05',
        category: 'Finishing',
        question: 'What should generally be done before painting a wall?',
        options: [
          'Prepare and clean the surface',
          'Remove the wall',
          'Flood the room',
          'Break the plaster',
        ],
        correctAnswer: 'Prepare and clean the surface',
      ),
      QuizQuestionModel(
        id: 'finishing_06',
        category: 'Finishing',
        question: 'What is a primer used for?',
        options: [
          'Preparing a surface before painting',
          'Cutting steel',
          'Lifting materials',
          'Mixing concrete',
        ],
        correctAnswer: 'Preparing a surface before painting',
      ),
      QuizQuestionModel(
        id: 'finishing_07',
        category: 'Finishing',
        question: 'Which finish is commonly applied to walls for decoration?',
        options: ['Paint', 'Rebar', 'Aggregate', 'Scaffolding'],
        correctAnswer: 'Paint',
      ),
      QuizQuestionModel(
        id: 'finishing_08',
        category: 'Finishing',
        question: 'What is polishing commonly used to improve?',
        options: [
          'Surface appearance',
          'Foundation depth',
          'Column height',
          'Soil strength',
        ],
        correctAnswer: 'Surface appearance',
      ),
      QuizQuestionModel(
        id: 'finishing_09',
        category: 'Finishing',
        question: 'What is a tile adhesive used for?',
        options: [
          'Fixing tiles to a surface',
          'Painting steel',
          'Testing concrete',
          'Supporting columns',
        ],
        correctAnswer: 'Fixing tiles to a surface',
      ),
      QuizQuestionModel(
        id: 'finishing_10',
        category: 'Finishing',
        question: 'Which activity is normally considered a finishing activity?',
        options: [
          'Wall painting',
          'Foundation excavation',
          'Column reinforcement',
          'Soil compaction',
        ],
        correctAnswer: 'Wall painting',
      ),

      // SITE SAFETY - 10
      QuizQuestionModel(
        id: 'safety_01',
        category: 'Site Safety',
        question: 'What should workers wear to protect their heads on a construction site?',
        options: ['Safety helmet', 'Sandals', 'Cap only', 'Scarf'],
        correctAnswer: 'Safety helmet',
      ),
      QuizQuestionModel(
        id: 'safety_02',
        category: 'Site Safety',
        question: 'What does PPE stand for?',
        options: [
          'Personal Protective Equipment',
          'Public Project Engineering',
          'Private Protection Entry',
          'Professional Plant Equipment',
        ],
        correctAnswer: 'Personal Protective Equipment',
      ),
      QuizQuestionModel(
        id: 'safety_03',
        category: 'Site Safety',
        question: 'What should be done around a dangerous work area?',
        options: [
          'Use appropriate barriers and warning signs',
          'Remove warning signs',
          'Allow unrestricted access',
          'Ignore the area',
        ],
        correctAnswer: 'Use appropriate barriers and warning signs',
      ),
      QuizQuestionModel(
        id: 'safety_04',
        category: 'Site Safety',
        question: 'Why are safety boots important on construction sites?',
        options: [
          'They help protect feet',
          'They improve painting',
          'They measure concrete',
          'They replace helmets',
        ],
        correctAnswer: 'They help protect feet',
      ),
      QuizQuestionModel(
        id: 'safety_05',
        category: 'Site Safety',
        question: 'What should workers do before operating unfamiliar equipment?',
        options: [
          'Receive proper instruction',
          'Operate it immediately',
          'Ignore the manual',
          'Remove safety guards',
        ],
        correctAnswer: 'Receive proper instruction',
      ),
      QuizQuestionModel(
        id: 'safety_06',
        category: 'Site Safety',
        question: 'Why should construction areas be kept tidy?',
        options: [
          'To reduce trip and fall hazards',
          'To increase noise',
          'To slow down work',
          'To remove safety equipment',
        ],
        correctAnswer: 'To reduce trip and fall hazards',
      ),
      QuizQuestionModel(
        id: 'safety_07',
        category: 'Site Safety',
        question: 'What should be used when working where there is a risk of falling?',
        options: [
          'Appropriate fall protection',
          'Regular shoes only',
          'A paint brush',
          'Loose rope without protection',
        ],
        correctAnswer: 'Appropriate fall protection',
      ),
      QuizQuestionModel(
        id: 'safety_08',
        category: 'Site Safety',
        question: 'What should be done if unsafe equipment is found?',
        options: [
          'Report it and stop using it',
          'Continue using it',
          'Hide the problem',
          'Remove all warning labels',
        ],
        correctAnswer: 'Report it and stop using it',
      ),
      QuizQuestionModel(
        id: 'safety_09',
        category: 'Site Safety',
        question: 'Why are safety signs used on construction sites?',
        options: [
          'To communicate hazards and precautions',
          'To decorate buildings',
          'To replace training',
          'To advertise products',
        ],
        correctAnswer: 'To communicate hazards and precautions',
      ),
      QuizQuestionModel(
        id: 'safety_10',
        category: 'Site Safety',
        question: 'What is an important response to a site emergency?',
        options: [
          'Follow the emergency procedure',
          'Ignore instructions',
          'Run into the hazard',
          'Remove emergency equipment',
        ],
        correctAnswer: 'Follow the emergency procedure',
      ),

      // TOOLS & MACHINERY - 10
      QuizQuestionModel(
        id: 'tools_01',
        category: 'Tools & Machinery',
        question: 'Which equipment is commonly used to lift heavy materials?',
        options: ['Crane', 'Trowel', 'Hammer', 'Spirit level'],
        correctAnswer: 'Crane',
      ),
      QuizQuestionModel(
        id: 'tools_02',
        category: 'Tools & Machinery',
        question: 'Which hand tool is commonly used to drive nails?',
        options: ['Hammer', 'Trowel', 'Shovel', 'Level'],
        correctAnswer: 'Hammer',
      ),
      QuizQuestionModel(
        id: 'tools_03',
        category: 'Tools & Machinery',
        question: 'Which tool is commonly used to spread mortar?',
        options: ['Trowel', 'Hammer', 'Drill', 'Saw'],
        correctAnswer: 'Trowel',
      ),
      QuizQuestionModel(
        id: 'tools_04',
        category: 'Tools & Machinery',
        question: 'What is a spirit level used for?',
        options: [
          'Checking level and alignment',
          'Cutting concrete',
          'Lifting steel',
          'Mixing paint',
        ],
        correctAnswer: 'Checking level and alignment',
      ),
      QuizQuestionModel(
        id: 'tools_05',
        category: 'Tools & Machinery',
        question: 'Which machine is commonly used to compact soil?',
        options: ['Compactor', 'Crane', 'Drill', 'Trowel'],
        correctAnswer: 'Compactor',
      ),
      QuizQuestionModel(
        id: 'tools_06',
        category: 'Tools & Machinery',
        question: 'Which tool is commonly used to make holes in materials?',
        options: ['Drill', 'Trowel', 'Level', 'Wheelbarrow'],
        correctAnswer: 'Drill',
      ),
      QuizQuestionModel(
        id: 'tools_07',
        category: 'Tools & Machinery',
        question: 'What is a wheelbarrow commonly used for?',
        options: [
          'Moving materials',
          'Checking levels',
          'Cutting steel',
          'Painting walls',
        ],
        correctAnswer: 'Moving materials',
      ),
      QuizQuestionModel(
        id: 'tools_08',
        category: 'Tools & Machinery',
        question: 'Which machine is commonly used to mix concrete?',
        options: ['Concrete mixer', 'Crane', 'Drill', 'Level'],
        correctAnswer: 'Concrete mixer',
      ),
      QuizQuestionModel(
        id: 'tools_09',
        category: 'Tools & Machinery',
        question: 'Which tool is commonly used to cut timber?',
        options: ['Saw', 'Trowel', 'Level', 'Wrench'],
        correctAnswer: 'Saw',
      ),
      QuizQuestionModel(
        id: 'tools_10',
        category: 'Tools & Machinery',
        question: 'What is a measuring tape mainly used for?',
        options: [
          'Measuring distances',
          'Mixing concrete',
          'Lifting materials',
          'Painting surfaces',
        ],
        correctAnswer: 'Measuring distances',
      ),
    ];
  }

  // --------------------------------------------------
  // DATA SEEDING HELPER (Idempotent initial data setup)
  // --------------------------------------------------

  Future<void> seedInitialDataIfNeeded() async {
    try {
      final articlesSnapshot =
          await _firestore.collection('articles').limit(1).get();

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
            'createdAt': FieldValue.serverTimestamp(),
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
            'createdAt': FieldValue.serverTimestamp(),
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
            'createdAt': FieldValue.serverTimestamp(),
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
            'createdAt': FieldValue.serverTimestamp(),
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
            'createdAt': FieldValue.serverTimestamp(),
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
            'createdAt': FieldValue.serverTimestamp(),
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
            'createdAt': FieldValue.serverTimestamp(),
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
            'createdAt': FieldValue.serverTimestamp(),
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
            'createdAt': FieldValue.serverTimestamp(),
          },
        ];

        final batch = _firestore.batch();
        for (final item in initialArticles) {
          final docRef = _firestore.collection('articles').doc();
          batch.set(docRef, item);
        }
        await batch.commit();
        debugPrint('Seeded initial articles into Firestore.');
      }
    } catch (e) {
      debugPrint('Error in seedInitialDataIfNeeded: $e');
    }
  }
}