import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  // ARTICLES
  // ==================================================

  Stream<List<Article>> getArticles() {
    return _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            return Article(
              id: doc.id,
              title: data['title']?.toString() ?? '',
              description: data['description']?.toString() ?? '',
              content: data['content']?.toString() ?? '',
              category: data['category']?.toString() ?? '',
              imageUrl: data['imageUrl']?.toString() ?? '',
            );
          }).toList();
        });
  }

  Stream<List<Article>> getArticlesByCategory(String category) {
    return _firestore
        .collection('articles')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            return Article(
              id: doc.id,
              title: data['title']?.toString() ?? '',
              description: data['description']?.toString() ?? '',
              content: data['content']?.toString() ?? '',
              category: data['category']?.toString() ?? '',
              imageUrl: data['imageUrl']?.toString() ?? '',
            );
          }).toList();
        });
  }

  Future<void> seedInitialDataIfNeeded() async {
    final quizSnapshot = await _firestore
        .collection('quizQuestions')
        .limit(1)
        .get();
    if (quizSnapshot.docs.isEmpty) {
      await seedQuizQuestions();
    }

    final mixtureSnapshot = await _firestore
        .collection('mixtureData')
        .limit(1)
        .get();
    if (mixtureSnapshot.docs.isEmpty) {
      await _seedCementMixtureData();
    }
  }

  Future<void> _seedCementMixtureData() async {
    final parentRef = _firestore.collection('mixtureData').doc('cement');
    final recordsRef = parentRef.collection('records');
    final existing = await recordsRef.limit(1).get();

    if (existing.docs.isNotEmpty) {
      return;
    }

    final records = [
      {
        'cement': 350,
        'blastFurnaceSlag': 50,
        'flyAsh': 50,
        'water': 175,
        'superplasticizer': 4.5,
        'coarseAggregate': 1100,
        'fineAggregate': 760,
        'age': 7,
        'compressiveStrength': 26.5,
      },
      {
        'cement': 380,
        'blastFurnaceSlag': 60,
        'flyAsh': 20,
        'water': 170,
        'superplasticizer': 5.0,
        'coarseAggregate': 1080,
        'fineAggregate': 740,
        'age': 14,
        'compressiveStrength': 33.2,
      },
      {
        'cement': 420,
        'blastFurnaceSlag': 30,
        'flyAsh': 30,
        'water': 165,
        'superplasticizer': 6.0,
        'coarseAggregate': 1060,
        'fineAggregate': 720,
        'age': 28,
        'compressiveStrength': 41.8,
      },
    ];

    final batch = _firestore.batch();
    for (var i = 0; i < records.length; i++) {
      batch.set(
        recordsRef.doc('mix_${(i + 1).toString().padLeft(2, '0')}'),
        records[i],
      );
    }

    await batch.commit();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMixtureDataSnapshot({
    required String articleId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('mixtureData')
        .doc(articleId)
        .collection('records')
        .orderBy('age')
        .orderBy('compressiveStrength', descending: true);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.limit(limit).get();
  }

  Future<ConcreteMixtureRecord?> getSampleMixtureRecord({
    required String articleId,
  }) async {
    final snapshot = await _firestore
        .collection('mixtureData')
        .doc(articleId)
        .collection('records')
        .orderBy('age')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final doc = snapshot.docs.first;
    return ConcreteMixtureRecord.fromMap(doc.id, doc.data());
  }

  // ==================================================
  // BOOKMARKS
  // ==================================================

  Future<void> addBookmark({
    required String title,
    String? articleId,
    required String description,
    String content = '',
    String category = '',
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final bookmarkId = articleId ?? title;

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
    required String title,
    String? articleId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final bookmarkId = articleId ?? title;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(bookmarkId)
        .delete();
  }

  Future<bool> isBookmarked({required String title, String? articleId}) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final bookmarkId = articleId ?? title;

    final document = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(bookmarkId)
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
  // QUIZ QUESTIONS
  // ==================================================

  Future<List<QuizQuestionModel>> fetchQuizQuestions(String category) async {
    try {
      final snapshot = await _firestore
          .collection('quizQuestions')
          .where('category', isEqualTo: category)
          .get();

      final questions = snapshot.docs.map((doc) {
        return QuizQuestionModel.fromMap(doc.id, doc.data());
      }).toList();

      questions.shuffle();

      return questions.take(10).toList();
    } on FirebaseException catch (e) {
      throw Exception(
        'Failed to load quiz questions '
        '(${e.code}): ${e.message}',
      );
    } catch (e) {
      throw Exception('Failed to load quiz questions: $e');
    }
  }

  // ==================================================
  // SEED QUIZ QUESTIONS
  // ==================================================

  Future<void> seedQuizQuestions() async {
    final questions = _quizQuestionBank();

    final batch = _firestore.batch();

    for (final question in questions) {
      final document = _firestore.collection('quizQuestions').doc(question.id);

      batch.set(document, question.toMap());
    }

    await batch.commit();
  }

  List<QuizQuestionModel> _quizQuestionBank() {
    return [
      // ============================================================
      // MATERIALS - 10 QUESTIONS
      // ============================================================
      QuizQuestionModel(
        id: 'mat_01',
        question: 'Which material is primarily used as a binder in concrete?',
        options: ['Cement', 'Sand', 'Coarse aggregate', 'Water'],
        correctAnswer: 'Cement',
        category: 'Materials',
        difficulty: 'Easy',
        optionExplanations: {
          'Cement':
              'Cement acts as the binding material that holds the concrete ingredients together.',
          'Sand':
              'Sand is a fine aggregate and provides bulk and stability to concrete.',
          'Coarse aggregate':
              'Coarse aggregate such as gravel provides volume and strength but is not the binder.',
          'Water':
              'Water reacts with cement during hydration but does not act as the binder itself.',
        },
      ),

      QuizQuestionModel(
        id: 'mat_02',
        question:
            'Which test is commonly used to measure the workability of fresh concrete?',
        options: [
          'Slump test',
          'Impact test',
          'Tensile test',
          'Compression test',
        ],
        correctAnswer: 'Slump test',
        category: 'Materials',
        difficulty: 'Easy',
        optionExplanations: {
          'Slump test':
              'The slump test measures the consistency and workability of fresh concrete.',
          'Impact test':
              'The impact test is generally used to assess toughness of materials, not fresh concrete workability.',
          'Tensile test':
              'A tensile test measures resistance to pulling forces.',
          'Compression test':
              'A compression test measures compressive strength rather than fresh concrete workability.',
        },
      ),

      QuizQuestionModel(
        id: 'mat_03',
        question: 'What is the main purpose of curing concrete?',
        options: [
          'To maintain moisture for hydration',
          'To increase its color',
          'To remove cement',
          'To reduce aggregate size',
        ],
        correctAnswer: 'To maintain moisture for hydration',
        category: 'Materials',
        difficulty: 'Easy',
        optionExplanations: {
          'To maintain moisture for hydration':
              'Curing keeps concrete sufficiently moist so cement hydration can continue and strength can develop.',
          'To increase its color':
              'Curing is not performed to change the color of concrete.',
          'To remove cement':
              'Cement is an essential ingredient and is not removed during curing.',
          'To reduce aggregate size':
              'Curing does not change the size of aggregate particles.',
        },
      ),

      QuizQuestionModel(
        id: 'mat_04',
        question: 'Which aggregate is generally called fine aggregate?',
        options: ['Sand', 'Gravel', 'Crushed stone', 'Boulders'],
        correctAnswer: 'Sand',
        category: 'Materials',
        difficulty: 'Easy',
        optionExplanations: {
          'Sand':
              'Sand consists of relatively small particles and is commonly classified as fine aggregate.',
          'Gravel': 'Gravel is normally classified as coarse aggregate.',
          'Crushed stone':
              'Crushed stone used in larger sizes is generally coarse aggregate.',
          'Boulders':
              'Boulders are much larger particles and are not normally classified as fine aggregate.',
        },
      ),

      QuizQuestionModel(
        id: 'mat_05',
        question:
            'What does the water-cement ratio mainly influence in concrete?',
        options: [
          'Strength and workability',
          'Brick color',
          'Steel diameter',
          'Wall height',
        ],
        correctAnswer: 'Strength and workability',
        category: 'Materials',
        difficulty: 'Medium',
        optionExplanations: {
          'Strength and workability':
              'The water-cement ratio strongly affects concrete strength, durability, and workability.',
          'Brick color':
              'Brick color is mainly related to the material composition and manufacturing process.',
          'Steel diameter':
              'Steel diameter is selected separately according to structural requirements.',
          'Wall height':
              'Wall height is a geometric design parameter and is not directly determined by water-cement ratio.',
        },
      ),

      QuizQuestionModel(
        id: 'mat_06',
        question:
            'Which material is commonly used to prevent corrosion of reinforcement by providing an alkaline environment?',
        options: ['Cement paste', 'Timber', 'Glass', 'Bitumen'],
        correctAnswer: 'Cement paste',
        category: 'Materials',
        difficulty: 'Medium',
        optionExplanations: {
          'Cement paste':
              'Hydrated cement paste provides an alkaline environment that helps protect embedded steel from corrosion.',
          'Timber':
              'Timber does not provide the alkaline protective environment required for reinforcement.',
          'Glass':
              'Glass is not responsible for protecting reinforcement inside concrete.',
          'Bitumen':
              'Bitumen is commonly used for waterproofing and roads, not for the alkaline protection of embedded reinforcement.',
        },
      ),

      QuizQuestionModel(
        id: 'mat_07',
        question:
            'Which property of steel makes it suitable for reinforcement in concrete?',
        options: [
          'High tensile strength',
          'Very low density',
          'High water absorption',
          'Poor bonding with concrete',
        ],
        correctAnswer: 'High tensile strength',
        category: 'Materials',
        difficulty: 'Medium',
        optionExplanations: {
          'High tensile strength':
              'Steel can resist significant tensile forces, complementing concrete which is weak in tension.',
          'Very low density':
              'Steel has relatively high density, so low density is not its main advantage here.',
          'High water absorption':
              'Steel should not absorb water; moisture can contribute to corrosion if protection is lost.',
          'Poor bonding with concrete':
              'Good bond between steel and concrete is important for effective reinforcement.',
        },
      ),

      QuizQuestionModel(
        id: 'mat_08',
        question: 'What is the purpose of using admixtures in concrete?',
        options: [
          'To modify concrete properties',
          'To completely replace aggregate',
          'To eliminate cement',
          'To increase brick size',
        ],
        correctAnswer: 'To modify concrete properties',
        category: 'Materials',
        difficulty: 'Medium',
        optionExplanations: {
          'To modify concrete properties':
              'Admixtures can improve workability, setting time, strength, durability, or other properties.',
          'To completely replace aggregate':
              'Admixtures are added in small quantities and do not normally replace all aggregate.',
          'To eliminate cement':
              'Admixtures modify concrete but do not normally eliminate the cement binder.',
          'To increase brick size':
              'Admixtures are used in concrete and other materials for property modification, not for increasing brick size.',
        },
      ),

      QuizQuestionModel(
        id: 'mat_09',
        question:
            'Which material is commonly used for waterproofing roofs and foundations?',
        options: ['Bitumen', 'Sand', 'Plain glass', 'Gypsum powder'],
        correctAnswer: 'Bitumen',
        category: 'Materials',
        difficulty: 'Easy',
        optionExplanations: {
          'Bitumen':
              'Bituminous membranes and coatings are widely used for waterproofing construction elements.',
          'Sand':
              'Sand is an aggregate and is not normally used as a waterproofing membrane.',
          'Plain glass':
              'Glass can resist water but is not normally used as a waterproofing coating.',
          'Gypsum powder':
              'Gypsum is mainly used in plaster and boards and is not suitable as a primary waterproofing material.',
        },
      ),

      QuizQuestionModel(
        id: 'mat_10',
        question:
            'What is the main purpose of reinforcement cover in reinforced concrete?',
        options: [
          'Protect reinforcement from corrosion and fire',
          'Increase brick size',
          'Reduce cement content',
          'Make concrete transparent',
        ],
        correctAnswer: 'Protect reinforcement from corrosion and fire',
        category: 'Materials',
        difficulty: 'Easy',
        optionExplanations: {
          'Protect reinforcement from corrosion and fire':
              'Concrete cover protects embedded steel from environmental exposure and provides fire resistance.',
          'Increase brick size':
              'Concrete cover is unrelated to brick dimensions.',
          'Reduce cement content':
              'Cover does not determine the required cement content.',
          'Make concrete transparent':
              'Concrete cover has no purpose related to transparency.',
        },
      ),

      // ============================================================
      // STRUCTURAL - 10 QUESTIONS
      // ============================================================
      QuizQuestionModel(
        id: 'str_01',
        question:
            'Which structural member primarily carries transverse loads and transfers them to supports?',
        options: ['Beam', 'Column', 'Footing', 'Wall paint'],
        correctAnswer: 'Beam',
        category: 'Structural',
        difficulty: 'Easy',
        optionExplanations: {
          'Beam':
              'A beam primarily resists bending and transfers loads to columns or other supports.',
          'Column':
              'A column mainly carries axial loads and transfers them toward the foundation.',
          'Footing':
              'A footing transfers structural loads from columns or walls to the soil.',
          'Wall paint':
              'Paint is a finishing material and does not act as a structural member.',
        },
      ),

      QuizQuestionModel(
        id: 'str_02',
        question:
            'What is the primary function of a column in a framed structure?',
        options: [
          'Transfer loads to the foundation',
          'Provide floor decoration',
          'Prevent paint peeling',
          'Measure room temperature',
        ],
        correctAnswer: 'Transfer loads to the foundation',
        category: 'Structural',
        difficulty: 'Easy',
        optionExplanations: {
          'Transfer loads to the foundation':
              'Columns carry loads from beams and floors and transfer them toward the foundation.',
          'Provide floor decoration':
              'Decoration is not the structural function of a column.',
          'Prevent paint peeling':
              'Paint performance is unrelated to the structural function of columns.',
          'Measure room temperature':
              'Temperature measurement is performed using sensors, not structural columns.',
        },
      ),

      QuizQuestionModel(
        id: 'str_03',
        question:
            'Which type of foundation is commonly used when good bearing soil is available near the surface?',
        options: [
          'Shallow foundation',
          'Deep foundation',
          'Suspended foundation',
          'Floating roof',
        ],
        correctAnswer: 'Shallow foundation',
        category: 'Structural',
        difficulty: 'Easy',
        optionExplanations: {
          'Shallow foundation':
              'Shallow foundations transfer loads to soil relatively close to ground level.',
          'Deep foundation':
              'Deep foundations transfer loads to deeper soil or rock and are used when surface soil is unsuitable.',
          'Suspended foundation':
              'This is not a standard general classification of foundation based on soil depth.',
          'Floating roof':
              'A floating roof is unrelated to building foundations.',
        },
      ),

      QuizQuestionModel(
        id: 'str_04',
        question: 'What type of stress is a column mainly designed to resist?',
        options: [
          'Compression',
          'Pure tension only',
          'Color change',
          'Water absorption',
        ],
        correctAnswer: 'Compression',
        category: 'Structural',
        difficulty: 'Easy',
        optionExplanations: {
          'Compression':
              'Columns primarily carry compressive axial loads, although they may also experience bending.',
          'Pure tension only':
              'Columns are generally not designed primarily as tension-only members.',
          'Color change': 'Color change is not a structural stress.',
          'Water absorption':
              'Water absorption is a material property, not a structural stress.',
        },
      ),

      QuizQuestionModel(
        id: 'str_05',
        question: 'What is the main purpose of a foundation?',
        options: [
          'Transfer building loads safely to the soil',
          'Decorate the building',
          'Provide electrical power',
          'Control room lighting',
        ],
        correctAnswer: 'Transfer building loads safely to the soil',
        category: 'Structural',
        difficulty: 'Easy',
        optionExplanations: {
          'Transfer building loads safely to the soil':
              'The foundation distributes structural loads to the ground without excessive settlement or failure.',
          'Decorate the building':
              'Decoration is not the primary purpose of a foundation.',
          'Provide electrical power':
              'Electrical systems provide power, not foundations.',
          'Control room lighting': 'Lighting systems perform this function.',
        },
      ),

      QuizQuestionModel(
        id: 'str_06',
        question:
            'Which structural element is commonly subjected to bending and shear?',
        options: [
          'Beam',
          'Foundation soil only',
          'Door handle',
          'Window glass',
        ],
        correctAnswer: 'Beam',
        category: 'Structural',
        difficulty: 'Medium',
        optionExplanations: {
          'Beam':
              'Beams commonly resist bending moments and shear forces due to transverse loads.',
          'Foundation soil only':
              'Soil supports the foundation but is not itself the typical structural member referred to here.',
          'Door handle':
              'A door handle is a fixture and is not normally analyzed as a building beam.',
          'Window glass':
              'Window glass is not normally designed as the primary beam of a structure.',
        },
      ),

      QuizQuestionModel(
        id: 'str_07',
        question:
            'What does a lintel generally support above a door or window opening?',
        options: [
          'Masonry or wall load above the opening',
          'Foundation soil',
          'Underground water',
          'Electrical current',
        ],
        correctAnswer: 'Masonry or wall load above the opening',
        category: 'Structural',
        difficulty: 'Easy',
        optionExplanations: {
          'Masonry or wall load above the opening':
              'A lintel spans the opening and supports loads from the masonry or wall above it.',
          'Foundation soil':
              'Foundation soil is supported and interacted with by foundations, not lintels.',
          'Underground water':
              'Water management is handled by drainage and waterproofing systems.',
          'Electrical current':
              'Electrical current is carried by conductors and cables.',
        },
      ),

      QuizQuestionModel(
        id: 'str_08',
        question: 'What is the purpose of a structural drawing?',
        options: [
          'Show structural components and their details',
          'Show only paint colors',
          'List only furniture',
          'Display weather forecasts',
        ],
        correctAnswer: 'Show structural components and their details',
        category: 'Structural',
        difficulty: 'Easy',
        optionExplanations: {
          'Show structural components and their details':
              'Structural drawings communicate sizes, reinforcement, dimensions, and construction details.',
          'Show only paint colors':
              'Paint colors are generally specified in architectural or finishing information.',
          'List only furniture':
              'Furniture layouts are not the main purpose of structural drawings.',
          'Display weather forecasts':
              'Weather forecasts come from meteorological information, not structural drawings.',
        },
      ),

      QuizQuestionModel(
        id: 'str_09',
        question: 'Which force tends to pull a structural member apart?',
        options: ['Tension', 'Compression', 'Bearing only', 'Temperature only'],
        correctAnswer: 'Tension',
        category: 'Structural',
        difficulty: 'Easy',
        optionExplanations: {
          'Tension':
              'Tension is a pulling force that tends to elongate a structural member.',
          'Compression': 'Compression pushes or squeezes a member together.',
          'Bearing only':
              'Bearing describes contact pressure rather than the general pulling action described here.',
          'Temperature only':
              'Temperature can cause expansion or contraction but is not itself the described pulling force.',
        },
      ),

      QuizQuestionModel(
        id: 'str_10',
        question: 'Why are expansion joints provided in some structures?',
        options: [
          'To accommodate movement caused by temperature and other effects',
          'To increase paint brightness',
          'To eliminate all reinforcement',
          'To reduce room height',
        ],
        correctAnswer:
            'To accommodate movement caused by temperature and other effects',
        category: 'Structural',
        difficulty: 'Medium',
        optionExplanations: {
          'To accommodate movement caused by temperature and other effects':
              'Expansion joints provide space for controlled movement and help reduce unwanted stresses.',
          'To increase paint brightness':
              'Joint design does not aim to improve paint brightness.',
          'To eliminate all reinforcement':
              'Expansion joints do not mean reinforcement is eliminated throughout a structure.',
          'To reduce room height':
              'Expansion joints are not used to reduce room height.',
        },
      ),

      // ============================================================
      // FINISHING - 10 QUESTIONS
      // ============================================================
      QuizQuestionModel(
        id: 'fin_01',
        question: 'What is the main purpose of plastering a wall?',
        options: [
          'Provide a smooth and protective surface',
          'Increase foundation depth',
          'Replace reinforcement',
          'Measure concrete strength',
        ],
        correctAnswer: 'Provide a smooth and protective surface',
        category: 'Finishing',
        difficulty: 'Easy',
        optionExplanations: {
          'Provide a smooth and protective surface':
              'Plaster improves the appearance and provides a protective layer over masonry or concrete surfaces.',
          'Increase foundation depth':
              'Foundation depth is determined during structural and geotechnical design.',
          'Replace reinforcement':
              'Plaster does not perform the function of reinforcement.',
          'Measure concrete strength':
              'Concrete strength is measured using appropriate testing methods, not plastering.',
        },
      ),

      QuizQuestionModel(
        id: 'fin_02',
        question: 'Why is primer applied before painting?',
        options: [
          'To improve adhesion and provide a suitable base',
          'To increase foundation load',
          'To replace plaster',
          'To reduce wall thickness',
        ],
        correctAnswer: 'To improve adhesion and provide a suitable base',
        category: 'Finishing',
        difficulty: 'Easy',
        optionExplanations: {
          'To improve adhesion and provide a suitable base':
              'Primer helps the finishing paint adhere properly and can improve surface uniformity.',
          'To increase foundation load':
              'Primer has no structural role in foundations.',
          'To replace plaster':
              'Primer is a coating preparation layer and does not replace plaster.',
          'To reduce wall thickness':
              'Primer does not significantly reduce structural wall thickness.',
        },
      ),

      QuizQuestionModel(
        id: 'fin_03',
        question: 'Which material is commonly used for floor tiling?',
        options: [
          'Ceramic tile',
          'Reinforcement bar',
          'Cement bag',
          'Structural steel beam',
        ],
        correctAnswer: 'Ceramic tile',
        category: 'Finishing',
        difficulty: 'Easy',
        optionExplanations: {
          'Ceramic tile':
              'Ceramic and porcelain tiles are commonly used as durable floor finishes.',
          'Reinforcement bar':
              'Reinforcement bars are structural materials placed inside concrete.',
          'Cement bag':
              'Cement is a construction material but is not itself a finished floor tile.',
          'Structural steel beam':
              'A steel beam is a structural component, not a typical floor finish.',
        },
      ),

      QuizQuestionModel(
        id: 'fin_04',
        question: 'What is putty commonly used for before painting?',
        options: [
          'Filling minor surface imperfections',
          'Constructing foundations',
          'Reinforcing columns',
          'Testing soil density',
        ],
        correctAnswer: 'Filling minor surface imperfections',
        category: 'Finishing',
        difficulty: 'Easy',
        optionExplanations: {
          'Filling minor surface imperfections':
              'Wall putty is used to create a smoother and more uniform surface before painting.',
          'Constructing foundations':
              'Foundation construction requires structural and foundation materials, not wall putty.',
          'Reinforcing columns':
              'Columns are reinforced using steel and concrete design principles.',
          'Testing soil density':
              'Soil density requires specific field or laboratory tests.',
        },
      ),

      QuizQuestionModel(
        id: 'fin_05',
        question: 'What is the purpose of waterproofing in a building?',
        options: [
          'Prevent unwanted water penetration',
          'Increase electrical voltage',
          'Reduce steel strength',
          'Change room temperature automatically',
        ],
        correctAnswer: 'Prevent unwanted water penetration',
        category: 'Finishing',
        difficulty: 'Easy',
        optionExplanations: {
          'Prevent unwanted water penetration':
              'Waterproofing protects building components from moisture and water ingress.',
          'Increase electrical voltage':
              'Electrical systems determine voltage, not waterproofing systems.',
          'Reduce steel strength':
              'Proper waterproofing generally helps protect materials rather than intentionally reducing their strength.',
          'Change room temperature automatically':
              'Temperature control is handled by HVAC and building systems.',
        },
      ),

      QuizQuestionModel(
        id: 'fin_06',
        question:
            'Which finish is commonly applied to walls for decorative appearance?',
        options: ['Paint', 'Rebar', 'Gravel', 'Structural concrete'],
        correctAnswer: 'Paint',
        category: 'Finishing',
        difficulty: 'Easy',
        optionExplanations: {
          'Paint':
              'Paint provides color, appearance, and in some cases additional surface protection.',
          'Rebar':
              'Rebar is reinforcement steel and is normally embedded in concrete.',
          'Gravel':
              'Gravel is an aggregate used in concrete and other applications.',
          'Structural concrete':
              'Concrete is a structural material and is not generally used as a decorative wall finish by itself.',
        },
      ),

      QuizQuestionModel(
        id: 'fin_07',
        question: 'Why should a surface be cleaned before applying paint?',
        options: [
          'To improve paint adhesion',
          'To increase concrete cover',
          'To reduce steel diameter',
          'To increase foundation width',
        ],
        correctAnswer: 'To improve paint adhesion',
        category: 'Finishing',
        difficulty: 'Easy',
        optionExplanations: {
          'To improve paint adhesion':
              'Removing dust, grease, and loose material helps the paint bond properly to the surface.',
          'To increase concrete cover':
              'Surface cleaning does not change reinforcement cover.',
          'To reduce steel diameter':
              'Cleaning a wall does not alter steel reinforcement.',
          'To increase foundation width':
              'Foundation dimensions are unrelated to paint surface preparation.',
        },
      ),

      QuizQuestionModel(
        id: 'fin_08',
        question: 'What is grouting commonly used for in tile installation?',
        options: [
          'Filling joints between tiles',
          'Casting columns',
          'Testing reinforcement',
          'Excavating soil',
        ],
        correctAnswer: 'Filling joints between tiles',
        category: 'Finishing',
        difficulty: 'Easy',
        optionExplanations: {
          'Filling joints between tiles':
              'Tile grout fills the spaces between tiles and helps provide a finished surface.',
          'Casting columns':
              'Columns are generally constructed using concrete and reinforcement according to design.',
          'Testing reinforcement':
              'Reinforcement testing uses appropriate inspection or laboratory methods.',
          'Excavating soil':
              'Excavation is performed using tools or machinery designed for earthwork.',
        },
      ),

      QuizQuestionModel(
        id: 'fin_09',
        question: 'What is false ceiling mainly used for?',
        options: [
          'Concealing services and improving interior appearance',
          'Supporting building foundations',
          'Replacing columns',
          'Increasing soil bearing capacity',
        ],
        correctAnswer: 'Concealing services and improving interior appearance',
        category: 'Finishing',
        difficulty: 'Easy',
        optionExplanations: {
          'Concealing services and improving interior appearance':
              'False ceilings can hide electrical, HVAC, and other services while improving the interior finish.',
          'Supporting building foundations':
              'Foundations transfer structural loads to soil; false ceilings do not.',
          'Replacing columns':
              'A false ceiling cannot replace a structural column.',
          'Increasing soil bearing capacity':
              'Soil bearing capacity is a geotechnical property and is not improved by false ceilings.',
        },
      ),

      QuizQuestionModel(
        id: 'fin_10',
        question: 'What is the purpose of polishing a finished floor?',
        options: [
          'Improve surface appearance and smoothness',
          'Increase foundation depth',
          'Replace structural reinforcement',
          'Measure wall thickness',
        ],
        correctAnswer: 'Improve surface appearance and smoothness',
        category: 'Finishing',
        difficulty: 'Easy',
        optionExplanations: {
          'Improve surface appearance and smoothness':
              'Polishing can improve the appearance, smoothness, and sometimes durability of suitable floor surfaces.',
          'Increase foundation depth':
              'Floor polishing does not affect foundation depth.',
          'Replace structural reinforcement':
              'Polishing is a finishing operation, not structural reinforcement.',
          'Measure wall thickness':
              'Wall thickness requires measurement tools or drawings, not floor polishing.',
        },
      ),

      // ============================================================
      // SITE SAFETY - 10 QUESTIONS
      // ============================================================
      QuizQuestionModel(
        id: 'safe_01',
        question: 'What does PPE stand for on a construction site?',
        options: [
          'Personal Protective Equipment',
          'Project Planning Estimate',
          'Public Property Entry',
          'Professional Project Engineering',
        ],
        correctAnswer: 'Personal Protective Equipment',
        category: 'Site Safety',
        difficulty: 'Easy',
        optionExplanations: {
          'Personal Protective Equipment':
              'PPE includes equipment such as helmets, safety shoes, gloves, goggles, and harnesses used to reduce exposure to hazards.',
          'Project Planning Estimate':
              'This is not the standard meaning of PPE in construction safety.',
          'Public Property Entry':
              'This is not the accepted construction safety abbreviation.',
          'Professional Project Engineering':
              'This is not what PPE means in site safety.',
        },
      ),

      QuizQuestionModel(
        id: 'safe_02',
        question:
            'Which PPE is primarily used to protect the head from falling objects?',
        options: [
          'Safety helmet',
          'Safety shoes',
          'Ear plugs',
          'Safety harness',
        ],
        correctAnswer: 'Safety helmet',
        category: 'Site Safety',
        difficulty: 'Easy',
        optionExplanations: {
          'Safety helmet':
              'A properly rated safety helmet helps protect the head from impacts and falling objects.',
          'Safety shoes':
              'Safety shoes primarily protect the feet from impacts and other hazards.',
          'Ear plugs': 'Ear plugs protect hearing from excessive noise.',
          'Safety harness':
              'A harness is primarily used as part of a fall-protection system.',
        },
      ),

      QuizQuestionModel(
        id: 'safe_03',
        question: 'What should be done before working at height?',
        options: [
          'Assess hazards and use appropriate fall protection',
          'Remove all PPE',
          'Ignore weather conditions',
          'Work without supervision or precautions',
        ],
        correctAnswer: 'Assess hazards and use appropriate fall protection',
        category: 'Site Safety',
        difficulty: 'Medium',
        optionExplanations: {
          'Assess hazards and use appropriate fall protection':
              'Working at height requires hazard assessment, suitable access, and appropriate fall-protection measures.',
          'Remove all PPE':
              'Removing PPE increases exposure to workplace hazards.',
          'Ignore weather conditions':
              'Weather can significantly affect work-at-height safety and should be considered.',
          'Work without supervision or precautions':
              'Working without proper controls increases the risk of accidents.',
        },
      ),

      QuizQuestionModel(
        id: 'safe_04',
        question: 'Why are safety signs used at construction sites?',
        options: [
          'To communicate hazards and required actions',
          'To decorate the site',
          'To increase concrete strength',
          'To measure building height',
        ],
        correctAnswer: 'To communicate hazards and required actions',
        category: 'Site Safety',
        difficulty: 'Easy',
        optionExplanations: {
          'To communicate hazards and required actions':
              'Safety signs warn workers about hazards, restrictions, emergency information, and required precautions.',
          'To decorate the site':
              'Safety signs have a safety communication purpose rather than a decorative purpose.',
          'To increase concrete strength':
              'Signs do not affect concrete properties.',
          'To measure building height':
              'Building dimensions are measured using appropriate surveying and measuring equipment.',
        },
      ),

      QuizQuestionModel(
        id: 'safe_05',
        question: 'What is a major hazard of an unprotected excavation?',
        options: [
          'Cave-in or collapse',
          'Paint fading',
          'Tile discoloration',
          'Low electrical frequency',
        ],
        correctAnswer: 'Cave-in or collapse',
        category: 'Site Safety',
        difficulty: 'Easy',
        optionExplanations: {
          'Cave-in or collapse':
              'Unsupported excavation sides can collapse and seriously injure or bury workers.',
          'Paint fading':
              'Paint fading is not the primary safety hazard of excavation.',
          'Tile discoloration':
              'Tile discoloration is a finishing issue, not an excavation safety hazard.',
          'Low electrical frequency':
              'Electrical hazards can exist near excavation, but low frequency is not the main general hazard described.',
        },
      ),

      QuizQuestionModel(
        id: 'safe_06',
        question: 'Why should construction walkways be kept clear?',
        options: [
          'To reduce trip and access hazards',
          'To increase wall thickness',
          'To improve cement hydration',
          'To reduce steel weight',
        ],
        correctAnswer: 'To reduce trip and access hazards',
        category: 'Site Safety',
        difficulty: 'Easy',
        optionExplanations: {
          'To reduce trip and access hazards':
              'Keeping walkways clear reduces slips, trips, falls, and blocked emergency access.',
          'To increase wall thickness':
              'Walkway housekeeping has no effect on wall thickness.',
          'To improve cement hydration':
              'Cement hydration occurs within concrete and is not affected by walkway cleanliness.',
          'To reduce steel weight':
              'Steel weight is determined by its dimensions and density.',
        },
      ),

      QuizQuestionModel(
        id: 'safe_07',
        question:
            'What is the purpose of a safety harness when working at height?',
        options: [
          'Help protect a worker from falling',
          'Increase concrete strength',
          'Carry construction materials',
          'Measure building dimensions',
        ],
        correctAnswer: 'Help protect a worker from falling',
        category: 'Site Safety',
        difficulty: 'Easy',
        optionExplanations: {
          'Help protect a worker from falling':
              'A properly used harness forms part of a personal fall-protection system.',
          'Increase concrete strength':
              'A harness has no effect on concrete strength.',
          'Carry construction materials':
              'A harness is not intended as a material-carrying device.',
          'Measure building dimensions':
              'Surveying and measuring tools are used for dimensions.',
        },
      ),

      QuizQuestionModel(
        id: 'safe_08',
        question:
            'Why should damaged electrical cables be removed from service?',
        options: [
          'They may cause electric shock or fire',
          'They reduce concrete strength',
          'They increase brick size',
          'They improve electrical safety',
        ],
        correctAnswer: 'They may cause electric shock or fire',
        category: 'Site Safety',
        difficulty: 'Easy',
        optionExplanations: {
          'They may cause electric shock or fire':
              'Damaged insulation or conductors can expose workers to shock, short circuits, or fire hazards.',
          'They reduce concrete strength':
              'Electrical cable damage does not directly reduce concrete strength.',
          'They increase brick size': 'Cables do not affect brick dimensions.',
          'They improve electrical safety':
              'Damaged cables reduce safety rather than improve it.',
        },
      ),

      QuizQuestionModel(
        id: 'safe_09',
        question:
            'What should workers do when they identify a serious site hazard?',
        options: [
          'Report it and follow the site safety procedure',
          'Ignore it',
          'Hide the hazard',
          'Continue without precautions',
        ],
        correctAnswer: 'Report it and follow the site safety procedure',
        category: 'Site Safety',
        difficulty: 'Easy',
        optionExplanations: {
          'Report it and follow the site safety procedure':
              'Reporting hazards allows appropriate controls to be implemented before someone is injured.',
          'Ignore it': 'Ignoring hazards allows unsafe conditions to continue.',
          'Hide the hazard':
              'Hiding hazards prevents proper corrective action.',
          'Continue without precautions':
              'Continuing without controls can expose workers to unnecessary risk.',
        },
      ),

      QuizQuestionModel(
        id: 'safe_10',
        question: 'Why is housekeeping important on a construction site?',
        options: [
          'It reduces hazards and keeps work areas organized',
          'It increases concrete setting time',
          'It replaces safety training',
          'It eliminates the need for PPE',
        ],
        correctAnswer: 'It reduces hazards and keeps work areas organized',
        category: 'Site Safety',
        difficulty: 'Easy',
        optionExplanations: {
          'It reduces hazards and keeps work areas organized':
              'Good housekeeping reduces trip hazards, improves access, and supports safer working conditions.',
          'It increases concrete setting time':
              'Housekeeping does not control concrete setting time.',
          'It replaces safety training':
              'Housekeeping is only one part of an overall safety program.',
          'It eliminates the need for PPE':
              'Good housekeeping does not eliminate the need for appropriate PPE.',
        },
      ),

      // ============================================================
      // TOOLS & MACHINERY - 10 QUESTIONS
      // ============================================================
      QuizQuestionModel(
        id: 'tool_01',
        question: 'Which machine is commonly used for excavating soil?',
        options: ['Excavator', 'Concrete mixer', 'Tower crane', 'Paint roller'],
        correctAnswer: 'Excavator',
        category: 'Tools & Machinery',
        difficulty: 'Easy',
        optionExplanations: {
          'Excavator':
              'An excavator is designed for digging, excavation, and material handling.',
          'Concrete mixer':
              'A concrete mixer is used to mix concrete ingredients.',
          'Tower crane':
              'A tower crane is primarily used for lifting and moving loads vertically and horizontally.',
          'Paint roller':
              'A paint roller is a hand tool used for applying paint.',
        },
      ),

      QuizQuestionModel(
        id: 'tool_02',
        question: 'What is the primary function of a concrete mixer?',
        options: [
          'Mix concrete ingredients uniformly',
          'Excavate foundations',
          'Lift steel beams',
          'Measure land levels',
        ],
        correctAnswer: 'Mix concrete ingredients uniformly',
        category: 'Tools & Machinery',
        difficulty: 'Easy',
        optionExplanations: {
          'Mix concrete ingredients uniformly':
              'A concrete mixer combines cement, water, aggregates, and other ingredients into a consistent mixture.',
          'Excavate foundations':
              'Excavation is commonly performed using excavators or other earthmoving equipment.',
          'Lift steel beams':
              'Cranes and lifting equipment are used for heavy lifting.',
          'Measure land levels':
              'Surveying instruments are used to measure levels and elevations.',
        },
      ),

      QuizQuestionModel(
        id: 'tool_03',
        question:
            'Which equipment is commonly used to lift heavy materials vertically on large construction sites?',
        options: ['Tower crane', 'Wheelbarrow', 'Hand saw', 'Spirit level'],
        correctAnswer: 'Tower crane',
        category: 'Tools & Machinery',
        difficulty: 'Easy',
        optionExplanations: {
          'Tower crane':
              'Tower cranes are designed to lift and move heavy loads across large construction sites.',
          'Wheelbarrow':
              'A wheelbarrow is useful for transporting smaller quantities of material manually.',
          'Hand saw':
              'A hand saw is used mainly for cutting materials such as timber.',
          'Spirit level':
              'A spirit level is used for checking horizontal or vertical alignment.',
        },
      ),

      QuizQuestionModel(
        id: 'tool_04',
        question: 'What is a spirit level used for?',
        options: [
          'Checking level and alignment',
          'Mixing concrete',
          'Cutting reinforcement',
          'Compacting soil',
        ],
        correctAnswer: 'Checking level and alignment',
        category: 'Tools & Machinery',
        difficulty: 'Easy',
        optionExplanations: {
          'Checking level and alignment':
              'A spirit level helps determine whether a surface is horizontal or vertical.',
          'Mixing concrete': 'Concrete mixers are used to mix concrete.',
          'Cutting reinforcement':
              'Rebar cutters or suitable cutting tools are used for reinforcement.',
          'Compacting soil':
              'Compactors and rollers are used for soil compaction.',
        },
      ),

      QuizQuestionModel(
        id: 'tool_05',
        question: 'Which equipment is commonly used to compact soil?',
        options: [
          'Vibratory roller',
          'Paint brush',
          'Concrete pump',
          'Tile cutter',
        ],
        correctAnswer: 'Vibratory roller',
        category: 'Tools & Machinery',
        difficulty: 'Easy',
        optionExplanations: {
          'Vibratory roller':
              'A vibratory roller uses vibration and weight to compact soil and granular materials.',
          'Paint brush': 'A paint brush is used for applying paint.',
          'Concrete pump':
              'A concrete pump transports concrete to placement locations.',
          'Tile cutter':
              'A tile cutter is used to cut tiles to the required dimensions.',
        },
      ),

      QuizQuestionModel(
        id: 'tool_06',
        question: 'What is a concrete vibrator used for?',
        options: [
          'Remove trapped air and compact fresh concrete',
          'Paint walls',
          'Cut glass',
          'Measure soil moisture',
        ],
        correctAnswer: 'Remove trapped air and compact fresh concrete',
        category: 'Tools & Machinery',
        difficulty: 'Medium',
        optionExplanations: {
          'Remove trapped air and compact fresh concrete':
              'Concrete vibrators help consolidate fresh concrete and reduce entrapped air voids.',
          'Paint walls':
              'Paint is applied using brushes, rollers, or spraying equipment.',
          'Cut glass': 'Glass requires specialized cutting tools.',
          'Measure soil moisture':
              'Soil moisture is measured using appropriate testing instruments.',
        },
      ),

      QuizQuestionModel(
        id: 'tool_07',
        question:
            'Which tool is commonly used to measure distance on a construction site?',
        options: [
          'Measuring tape',
          'Concrete vibrator',
          'Jackhammer',
          'Trowel',
        ],
        correctAnswer: 'Measuring tape',
        category: 'Tools & Machinery',
        difficulty: 'Easy',
        optionExplanations: {
          'Measuring tape':
              'A measuring tape is a basic tool for measuring lengths and distances.',
          'Concrete vibrator':
              'A concrete vibrator consolidates fresh concrete.',
          'Jackhammer':
              'A jackhammer is used for breaking hard materials such as concrete.',
          'Trowel':
              'A trowel is commonly used for placing, spreading, or finishing mortar and concrete.',
        },
      ),

      QuizQuestionModel(
        id: 'tool_08',
        question: 'What is a concrete pump mainly used for?',
        options: [
          'Transporting concrete to the placement location',
          'Testing steel strength',
          'Painting walls',
          'Compacting soil',
        ],
        correctAnswer: 'Transporting concrete to the placement location',
        category: 'Tools & Machinery',
        difficulty: 'Medium',
        optionExplanations: {
          'Transporting concrete to the placement location':
              'Concrete pumps move fresh concrete through pipes or hoses to difficult or elevated placement locations.',
          'Testing steel strength':
              'Steel strength is assessed using suitable testing equipment and procedures.',
          'Painting walls': 'Painting equipment is used for wall finishing.',
          'Compacting soil':
              'Compaction equipment such as rollers and compactors is used for soil.',
        },
      ),

      QuizQuestionModel(
        id: 'tool_09',
        question: 'Which tool is commonly used to spread and finish mortar?',
        options: ['Trowel', 'Crane', 'Excavator', 'Roller compactor'],
        correctAnswer: 'Trowel',
        category: 'Tools & Machinery',
        difficulty: 'Easy',
        optionExplanations: {
          'Trowel':
              'A trowel is a hand tool commonly used to spread, shape, and finish mortar.',
          'Crane': 'A crane is used for lifting and moving heavy loads.',
          'Excavator':
              'An excavator is mainly used for digging and earthmoving.',
          'Roller compactor':
              'A roller compactor is used to compact soil and granular materials.',
        },
      ),

      QuizQuestionModel(
        id: 'tool_10',
        question:
            'What is a total station commonly used for in construction surveying?',
        options: [
          'Measuring angles, distances, and positions',
          'Mixing concrete',
          'Cutting timber',
          'Compacting concrete',
        ],
        correctAnswer: 'Measuring angles, distances, and positions',
        category: 'Tools & Machinery',
        difficulty: 'Medium',
        optionExplanations: {
          'Measuring angles, distances, and positions':
              'A total station combines electronic angle and distance measurement for surveying and setting out.',
          'Mixing concrete': 'Concrete mixers perform concrete mixing.',
          'Cutting timber': 'Saws and other cutting tools are used for timber.',
          'Compacting concrete':
              'Concrete vibrators are commonly used for concrete consolidation.',
        },
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
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }
}
