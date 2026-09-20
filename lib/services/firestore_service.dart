import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/article.dart';
import '../models/quiz_question.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

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

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>>
      getUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
  }

  // ==================================================
  // ARTICLES
  // ==================================================

  Stream<List<Article>> getArticles() {
    return _firestore
        .collection('articles')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return Article(
          id: doc.id,
          title: data['title']?.toString() ?? '',
          description:
              data['description']?.toString() ?? '',
          content: data['content']?.toString() ?? '',
          category:
              data['category']?.toString() ?? '',
          imageUrl:
              data['imageUrl']?.toString() ?? '',
        );
      }).toList();
    });
  }

  Future<List<Article>> getArticlesByCategory(
    String category,
  ) async {
    final snapshot = await _firestore
        .collection('articles')
        .where(
          'category',
          isEqualTo: category,
        )
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Article(
        id: doc.id,
        title: data['title']?.toString() ?? '',
        description:
            data['description']?.toString() ?? '',
        content:
            data['content']?.toString() ?? '',
        category:
            data['category']?.toString() ?? '',
        imageUrl:
            data['imageUrl']?.toString() ?? '',
      );
    }).toList();
  }

  // ==================================================
  // BOOKMARKS
  // ==================================================

  Future<void> addBookmark({
    required String title,
    required String description,
    String content = '',
    String category = '',
    String imageUrl = '',
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
      'imageUrl': imageUrl,
      'createdAt':
          FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark({
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

  Future<bool> isBookmarked({
    required String title,
  }) async {
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

  Stream<List<Map<String, dynamic>>>
      getBookmarks() {
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
                  ...doc.data(),
                },
              )
              .toList(),
        );
  }

  // ==================================================
  // QUIZ QUESTIONS
  // ==================================================

  Future<List<QuizQuestionModel>>
      fetchQuizQuestions(
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

      final questions = snapshot.docs.map((doc) {
        return QuizQuestionModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();

      questions.shuffle();

      return questions.take(10).toList();
    } on FirebaseException catch (e) {
      throw Exception(
        'Failed to load quiz questions '
        '(${e.code}): ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Failed to load quiz questions: $e',
      );
    }
  }

  // ==================================================
  // SEED QUIZ QUESTIONS
  // ==================================================

  Future<void> seedQuizQuestions() async {
    final questions = _quizQuestionBank();

    final batch = _firestore.batch();

    for (final question in questions) {
      final document = _firestore
          .collection('quizQuestions')
          .doc(question.id);

      batch.set(
        document,
        question.toMap(),
      );
    }

    await batch.commit();
  }

  List<QuizQuestionModel> _quizQuestionBank() {
    return [
      // ==================================================
      // MATERIALS - 10
      // ==================================================

      QuizQuestionModel(
        id: 'materials_01',
        category: 'Materials',
        question:
            'Which material is commonly used as a binder in concrete?',
        options: [
          'Cement',
          'Timber',
          'Glass',
          'Plastic',
        ],
        correctAnswer: 'Cement',
      ),

      QuizQuestionModel(
        id: 'materials_02',
        category: 'Materials',
        question:
            'Which material is commonly used for masonry walls?',
        options: [
          'Brick',
          'Rubber',
          'Paper',
          'Foam',
        ],
        correctAnswer: 'Brick',
      ),

      QuizQuestionModel(
        id: 'materials_03',
        category: 'Materials',
        question:
            'Which material is commonly used as reinforcement in concrete?',
        options: [
          'Steel',
          'Cardboard',
          'Cloth',
          'Glass',
        ],
        correctAnswer: 'Steel',
      ),

      QuizQuestionModel(
        id: 'materials_04',
        category: 'Materials',
        question:
            'What is concrete generally made from?',
        options: [
          'Cement, water and aggregates',
          'Wood and glass',
          'Plastic and rubber',
          'Steel and timber only',
        ],
        correctAnswer:
            'Cement, water and aggregates',
      ),

      QuizQuestionModel(
        id: 'materials_05',
        category: 'Materials',
        question:
            'Which material is commonly used for window glazing?',
        options: [
          'Glass',
          'Concrete',
          'Brick',
          'Bitumen',
        ],
        correctAnswer: 'Glass',
      ),

      QuizQuestionModel(
        id: 'materials_06',
        category: 'Materials',
        question:
            'Which material is commonly used for waterproofing roofs?',
        options: [
          'Bitumen',
          'Brick',
          'Timber',
          'Sand',
        ],
        correctAnswer: 'Bitumen',
      ),

      QuizQuestionModel(
        id: 'materials_07',
        category: 'Materials',
        question:
            'Which natural material is commonly used in traditional construction?',
        options: [
          'Stone',
          'Plastic',
          'Nylon',
          'Foam',
        ],
        correctAnswer: 'Stone',
      ),

      QuizQuestionModel(
        id: 'materials_08',
        category: 'Materials',
        question:
            'What is aggregate used for in concrete?',
        options: [
          'To provide bulk and strength',
          'To provide electrical power',
          'To paint concrete',
          'To replace all cement',
        ],
        correctAnswer:
            'To provide bulk and strength',
      ),

      QuizQuestionModel(
        id: 'materials_09',
        category: 'Materials',
        question:
            'Which material is commonly used for structural timber framing?',
        options: [
          'Wood',
          'Glass',
          'Cement',
          'Ceramic',
        ],
        correctAnswer: 'Wood',
      ),

      QuizQuestionModel(
        id: 'materials_10',
        category: 'Materials',
        question:
            'Which material is commonly used to make floor tiles?',
        options: [
          'Ceramic',
          'Paper',
          'Rubber',
          'Timber only',
        ],
        correctAnswer: 'Ceramic',
      ),

      // ==================================================
      // STRUCTURAL - 10
      // ==================================================

      QuizQuestionModel(
        id: 'structural_01',
        category: 'Structural',
        question:
            'What is the main purpose of a building foundation?',
        options: [
          'Transfer loads to the ground',
          'Decorate the building',
          'Provide lighting',
          'Paint the walls',
        ],
        correctAnswer:
            'Transfer loads to the ground',
      ),

      QuizQuestionModel(
        id: 'structural_02',
        category: 'Structural',
        question:
            'Which structural member primarily carries loads horizontally?',
        options: [
          'Beam',
          'Column',
          'Foundation',
          'Wall finish',
        ],
        correctAnswer: 'Beam',
      ),

      QuizQuestionModel(
        id: 'structural_03',
        category: 'Structural',
        question:
            'Which structural member primarily carries vertical loads?',
        options: [
          'Column',
          'Beam',
          'Tile',
          'Ceiling paint',
        ],
        correctAnswer: 'Column',
      ),

      QuizQuestionModel(
        id: 'structural_04',
        category: 'Structural',
        question:
            'What does a slab generally provide in a building?',
        options: [
          'A horizontal structural surface',
          'Only wall decoration',
          'Electrical wiring',
          'Water storage',
        ],
        correctAnswer:
            'A horizontal structural surface',
      ),

      QuizQuestionModel(
        id: 'structural_05',
        category: 'Structural',
        question:
            'What is reinforced concrete?',
        options: [
          'Concrete combined with reinforcement',
          'Concrete without cement',
          'Wood mixed with glass',
          'Brick mixed with paint',
        ],
        correctAnswer:
            'Concrete combined with reinforcement',
      ),

      QuizQuestionModel(
        id: 'structural_06',
        category: 'Structural',
        question:
            'What is a column mainly designed to resist?',
        options: [
          'Compression',
          'Painting',
          'Water absorption only',
          'Decoration',
        ],
        correctAnswer: 'Compression',
      ),

      QuizQuestionModel(
        id: 'structural_07',
        category: 'Structural',
        question:
            'What connects a building structure to its foundation?',
        options: [
          'Structural support system',
          'Paint coating',
          'Floor tile',
          'Window glass',
        ],
        correctAnswer:
            'Structural support system',
      ),

      QuizQuestionModel(
        id: 'structural_08',
        category: 'Structural',
        question:
            'Which type of foundation is commonly used for individual columns?',
        options: [
          'Isolated footing',
          'Roof slab',
          'Lintel',
          'Parapet',
        ],
        correctAnswer: 'Isolated footing',
      ),

      QuizQuestionModel(
        id: 'structural_09',
        category: 'Structural',
        question:
            'What is the purpose of structural reinforcement?',
        options: [
          'Improve load-carrying performance',
          'Change wall color',
          'Provide lighting',
          'Seal windows',
        ],
        correctAnswer:
            'Improve load-carrying performance',
      ),

      QuizQuestionModel(
        id: 'structural_10',
        category: 'Structural',
        question:
            'Which element is commonly used above a door or window opening?',
        options: [
          'Lintel',
          'Foundation',
          'Footing',
          'Floor tile',
        ],
        correctAnswer: 'Lintel',
      ),

      // ==================================================
      // FINISHING - 10
      // ==================================================

      QuizQuestionModel(
        id: 'finishing_01',
        category: 'Finishing',
        question:
            'What is plastering mainly used for?',
        options: [
          'Creating a smooth wall surface',
          'Making foundations',
          'Lifting materials',
          'Testing soil',
        ],
        correctAnswer:
            'Creating a smooth wall surface',
      ),

      QuizQuestionModel(
        id: 'finishing_02',
        category: 'Finishing',
        question:
            'What is the purpose of painting a wall?',
        options: [
          'Protection and appearance',
          'Structural reinforcement',
          'Foundation support',
          'Soil testing',
        ],
        correctAnswer:
            'Protection and appearance',
      ),

      QuizQuestionModel(
        id: 'finishing_03',
        category: 'Finishing',
        question:
            'Which material is commonly used for floor finishing?',
        options: [
          'Tiles',
          'Rebar',
          'Cement bags only',
          'Scaffolding',
        ],
        correctAnswer: 'Tiles',
      ),

      QuizQuestionModel(
        id: 'finishing_04',
        category: 'Finishing',
        question:
            'What is grouting commonly used for?',
        options: [
          'Filling joints between tiles',
          'Lifting concrete',
          'Testing steel',
          'Building foundations',
        ],
        correctAnswer:
            'Filling joints between tiles',
      ),

      QuizQuestionModel(
        id: 'finishing_05',
        category: 'Finishing',
        question:
            'What should generally be done before painting a wall?',
        options: [
          'Prepare and clean the surface',
          'Remove the wall',
          'Flood the room',
          'Break the plaster',
        ],
        correctAnswer:
            'Prepare and clean the surface',
      ),

      QuizQuestionModel(
        id: 'finishing_06',
        category: 'Finishing',
        question:
            'What is a primer used for?',
        options: [
          'Preparing a surface before painting',
          'Cutting steel',
          'Lifting materials',
          'Mixing concrete',
        ],
        correctAnswer:
            'Preparing a surface before painting',
      ),

      QuizQuestionModel(
        id: 'finishing_07',
        category: 'Finishing',
        question:
            'Which finish is commonly applied to walls for decoration?',
        options: [
          'Paint',
          'Rebar',
          'Aggregate',
          'Scaffolding',
        ],
        correctAnswer: 'Paint',
      ),

      QuizQuestionModel(
        id: 'finishing_08',
        category: 'Finishing',
        question:
            'What is polishing commonly used to improve?',
        options: [
          'Surface appearance',
          'Foundation depth',
          'Column height',
          'Soil strength',
        ],
        correctAnswer:
            'Surface appearance',
      ),

      QuizQuestionModel(
        id: 'finishing_09',
        category: 'Finishing',
        question:
            'What is a tile adhesive used for?',
        options: [
          'Fixing tiles to a surface',
          'Painting steel',
          'Testing concrete',
          'Supporting columns',
        ],
        correctAnswer:
            'Fixing tiles to a surface',
      ),

      QuizQuestionModel(
        id: 'finishing_10',
        category: 'Finishing',
        question:
            'Which activity is normally considered a finishing activity?',
        options: [
          'Wall painting',
          'Foundation excavation',
          'Column reinforcement',
          'Soil compaction',
        ],
        correctAnswer: 'Wall painting',
      ),

      // ==================================================
      // SITE SAFETY - 10
      // ==================================================

      QuizQuestionModel(
        id: 'safety_01',
        category: 'Site Safety',
        question:
            'What should workers wear to protect their heads on a construction site?',
        options: [
          'Safety helmet',
          'Sandals',
          'Cap only',
          'Scarf',
        ],
        correctAnswer: 'Safety helmet',
      ),

      QuizQuestionModel(
        id: 'safety_02',
        category: 'Site Safety',
        question:
            'What does PPE stand for?',
        options: [
          'Personal Protective Equipment',
          'Public Project Engineering',
          'Private Protection Entry',
          'Professional Plant Equipment',
        ],
        correctAnswer:
            'Personal Protective Equipment',
      ),

      QuizQuestionModel(
        id: 'safety_03',
        category: 'Site Safety',
        question:
            'What should be done around a dangerous work area?',
        options: [
          'Use appropriate barriers and warning signs',
          'Remove warning signs',
          'Allow unrestricted access',
          'Ignore the area',
        ],
        correctAnswer:
            'Use appropriate barriers and warning signs',
      ),

      QuizQuestionModel(
        id: 'safety_04',
        category: 'Site Safety',
        question:
            'Why are safety boots important on construction sites?',
        options: [
          'They help protect feet',
          'They improve painting',
          'They measure concrete',
          'They replace helmets',
        ],
        correctAnswer:
            'They help protect feet',
      ),

      QuizQuestionModel(
        id: 'safety_05',
        category: 'Site Safety',
        question:
            'What should workers do before operating unfamiliar equipment?',
        options: [
          'Receive proper instruction',
          'Operate it immediately',
          'Ignore the manual',
          'Remove safety guards',
        ],
        correctAnswer:
            'Receive proper instruction',
      ),

      QuizQuestionModel(
        id: 'safety_06',
        category: 'Site Safety',
        question:
            'Why should construction areas be kept tidy?',
        options: [
          'To reduce trip and fall hazards',
          'To increase noise',
          'To slow down work',
          'To remove safety equipment',
        ],
        correctAnswer:
            'To reduce trip and fall hazards',
      ),

      QuizQuestionModel(
        id: 'safety_07',
        category: 'Site Safety',
        question:
            'What should be used when working where there is a risk of falling?',
        options: [
          'Appropriate fall protection',
          'Regular shoes only',
          'A paint brush',
          'Loose rope without protection',
        ],
        correctAnswer:
            'Appropriate fall protection',
      ),

      QuizQuestionModel(
        id: 'safety_08',
        category: 'Site Safety',
        question:
            'What should be done if unsafe equipment is found?',
        options: [
          'Report it and stop using it',
          'Continue using it',
          'Hide the problem',
          'Remove all warning labels',
        ],
        correctAnswer:
            'Report it and stop using it',
      ),

      QuizQuestionModel(
        id: 'safety_09',
        category: 'Site Safety',
        question:
            'Why are safety signs used on construction sites?',
        options: [
          'To communicate hazards and precautions',
          'To decorate buildings',
          'To replace training',
          'To advertise products',
        ],
        correctAnswer:
            'To communicate hazards and precautions',
      ),

      QuizQuestionModel(
        id: 'safety_10',
        category: 'Site Safety',
        question:
            'What is an important response to a site emergency?',
        options: [
          'Follow the emergency procedure',
          'Ignore instructions',
          'Run into the hazard',
          'Remove emergency equipment',
        ],
        correctAnswer:
            'Follow the emergency procedure',
      ),

      // ==================================================
      // TOOLS & MACHINERY - 10
      // ==================================================

      QuizQuestionModel(
        id: 'tools_01',
        category: 'Tools & Machinery',
        question:
            'Which equipment is commonly used to lift heavy materials?',
        options: [
          'Crane',
          'Trowel',
          'Hammer',
          'Spirit level',
        ],
        correctAnswer: 'Crane',
      ),

      QuizQuestionModel(
        id: 'tools_02',
        category: 'Tools & Machinery',
        question:
            'Which hand tool is commonly used to drive nails?',
        options: [
          'Hammer',
          'Trowel',
          'Shovel',
          'Level',
        ],
        correctAnswer: 'Hammer',
      ),

      QuizQuestionModel(
        id: 'tools_03',
        category: 'Tools & Machinery',
        question:
            'Which tool is commonly used to spread mortar?',
        options: [
          'Trowel',
          'Hammer',
          'Drill',
          'Saw',
        ],
        correctAnswer: 'Trowel',
      ),

      QuizQuestionModel(
        id: 'tools_04',
        category: 'Tools & Machinery',
        question:
            'What is a spirit level used for?',
        options: [
          'Checking level and alignment',
          'Cutting concrete',
          'Lifting steel',
          'Mixing paint',
        ],
        correctAnswer:
            'Checking level and alignment',
      ),

      QuizQuestionModel(
        id: 'tools_05',
        category: 'Tools & Machinery',
        question:
            'Which machine is commonly used to compact soil?',
        options: [
          'Compactor',
          'Crane',
          'Drill',
          'Trowel',
        ],
        correctAnswer: 'Compactor',
      ),

      QuizQuestionModel(
        id: 'tools_06',
        category: 'Tools & Machinery',
        question:
            'Which tool is commonly used to make holes in materials?',
        options: [
          'Drill',
          'Trowel',
          'Level',
          'Wheelbarrow',
        ],
        correctAnswer: 'Drill',
      ),

      QuizQuestionModel(
        id: 'tools_07',
        category: 'Tools & Machinery',
        question:
            'What is a wheelbarrow commonly used for?',
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
        question:
            'Which machine is commonly used to mix concrete?',
        options: [
          'Concrete mixer',
          'Crane',
          'Drill',
          'Level',
        ],
        correctAnswer: 'Concrete mixer',
      ),

      QuizQuestionModel(
        id: 'tools_09',
        category: 'Tools & Machinery',
        question:
            'Which tool is commonly used to cut timber?',
        options: [
          'Saw',
          'Trowel',
          'Level',
          'Wrench',
        ],
        correctAnswer: 'Saw',
      ),

      QuizQuestionModel(
        id: 'tools_10',
        category: 'Tools & Machinery',
        question:
            'What is a measuring tape mainly used for?',
        options: [
          'Measuring distances',
          'Mixing concrete',
          'Lifting materials',
          'Painting surfaces',
        ],
        correctAnswer:
            'Measuring distances',
      ),
    ];
  }

  // ==================================================
  // QUIZ RESULTS / HISTORY
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

    final percentage = totalQuestions == 0
        ? 0
        : ((score / totalQuestions) * 100)
            .round();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('quizHistory')
        .add({
      'category': category,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'completedAt':
          FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>>
      getQuizHistory() {
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
}