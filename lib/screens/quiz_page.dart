import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import 'quiz_history_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final FirestoreService _firestoreService = FirestoreService();

  String? selectedCategory;

  int currentQuestion = 0;
  int score = 0;
  int? selectedAnswer;

  bool isLoading = false;

  List<Map<String, dynamic>> currentQuestions = [];

  final Map<String, List<Map<String, dynamic>>> localQuestions = {
    'Materials': [
      {
        'question': 'Which material is commonly used to make concrete?',
        'options': [
          'Cement',
          'Wood',
          'Glass',
          'Plastic',
        ],
        'answer': 0,
      },
      {
        'question': 'Which material is commonly used for reinforcement in concrete?',
        'options': [
          'Paper',
          'Rubber',
          'Steel',
          'Plastic',
        ],
        'answer': 2,
      },
      {
        'question': 'Which material is commonly used for masonry walls?',
        'options': [
          'Bricks',
          'Glass',
          'Rubber',
          'Cloth',
        ],
        'answer': 0,
      },
      {
        'question': 'Which material is commonly used to produce mortar?',
        'options': [
          'Cement',
          'Plastic',
          'Aluminium',
          'Glass',
        ],
        'answer': 0,
      },
      {
        'question': 'Which material is known for high tensile strength?',
        'options': [
          'Steel',
          'Clay',
          'Wood',
          'Sand',
        ],
        'answer': 0,
      },
      {
        'question': 'What is a major ingredient in concrete?',
        'options': [
          'Cement',
          'Paper',
          'Fabric',
          'Rubber',
        ],
        'answer': 0,
      },
      {
        'question': 'Which material is commonly used for insulation?',
        'options': [
          'Mineral wool',
          'Steel',
          'Concrete',
          'Brick',
        ],
        'answer': 0,
      },
      {
        'question': 'Which material is commonly used for glass production?',
        'options': [
          'Silica sand',
          'Cement',
          'Steel',
          'Gravel',
        ],
        'answer': 0,
      },
      {
        'question': 'Which material is commonly used as a fine aggregate?',
        'options': [
          'Sand',
          'Steel',
          'Brick',
          'Glass',
        ],
        'answer': 0,
      },
      {
        'question': 'Which material is commonly used as coarse aggregate?',
        'options': [
          'Gravel',
          'Paper',
          'Wood',
          'Plastic',
        ],
        'answer': 0,
      },
    ],

    'Structural': [
      {
        'question': 'What is the main purpose of a foundation?',
        'options': [
          'To decorate the building',
          'To transfer building loads to the ground',
          'To paint the building',
          'To provide lighting',
        ],
        'answer': 1,
      },
      {
        'question': 'Which structural member mainly carries bending loads?',
        'options': [
          'Beam',
          'Wall paint',
          'Door',
          'Window',
        ],
        'answer': 0,
      },
      {
        'question': 'Which structural member is mainly vertical?',
        'options': [
          'Column',
          'Beam',
          'Slab',
          'Roof tile',
        ],
        'answer': 0,
      },
      {
        'question': 'What does a slab primarily provide?',
        'options': [
          'Floor or roof surface',
          'Paint',
          'Lighting',
          'Drainage only',
        ],
        'answer': 0,
      },
      {
        'question': 'Which structure transfers loads to the foundation?',
        'options': [
          'Columns',
          'Paint',
          'Tiles',
          'Windows',
        ],
        'answer': 0,
      },
      {
        'question': 'What does RCC stand for?',
        'options': [
          'Reinforced Cement Concrete',
          'Rapid Construction Cement',
          'Road Construction Concrete',
          'Reinforced Clay Construction',
        ],
        'answer': 0,
      },
      {
        'question': 'Which force tends to stretch a structural member?',
        'options': [
          'Tension',
          'Compression',
          'None',
          'Friction only',
        ],
        'answer': 0,
      },
      {
        'question': 'Which force tends to shorten a structural member?',
        'options': [
          'Compression',
          'Tension',
          'Rotation',
          'Expansion only',
        ],
        'answer': 0,
      },
      {
        'question': 'What is a column designed primarily to resist?',
        'options': [
          'Vertical loads',
          'Paint',
          'Water only',
          'Lighting',
        ],
        'answer': 0,
      },
      {
        'question': 'Which part of a building transfers loads to soil?',
        'options': [
          'Foundation',
          'Window',
          'Door',
          'Ceiling paint',
        ],
        'answer': 0,
      },
    ],

    'Finishing': [
      {
        'question': 'What is plastering mainly used for?',
        'options': [
          'Smoothing and protecting walls',
          'Making steel',
          'Digging foundations',
          'Lifting materials',
        ],
        'answer': 0,
      },
      {
        'question': 'What is wall putty used for?',
        'options': [
          'Creating a smooth surface',
          'Structural reinforcement',
          'Excavation',
          'Concrete mixing',
        ],
        'answer': 0,
      },
      {
        'question': 'Which material is commonly used for floor finishing?',
        'options': [
          'Tiles',
          'Steel bars',
          'Sandbags',
          'Rebar',
        ],
        'answer': 0,
      },
      {
        'question': 'What is painting primarily used for?',
        'options': [
          'Protection and decoration',
          'Foundation design',
          'Load transfer',
          'Excavation',
        ],
        'answer': 0,
      },
      {
        'question': 'Which finish can be applied to walls for decoration?',
        'options': [
          'Paint',
          'Rebar',
          'Aggregate',
          'Concrete block only',
        ],
        'answer': 0,
      },
      {
        'question': 'What is tiling commonly used for?',
        'options': [
          'Floor and wall finishes',
          'Foundation excavation',
          'Steel reinforcement',
          'Concrete testing',
        ],
        'answer': 0,
      },
      {
        'question': 'What does primer help with before painting?',
        'options': [
          'Surface preparation',
          'Foundation depth',
          'Steel cutting',
          'Concrete mixing',
        ],
        'answer': 0,
      },
      {
        'question': 'What is grouting commonly associated with?',
        'options': [
          'Filling joints',
          'Cutting steel',
          'Excavating soil',
          'Lifting cranes',
        ],
        'answer': 0,
      },
      {
        'question': 'What is a smooth wall finish useful for?',
        'options': [
          'Better appearance',
          'Increasing foundation depth',
          'Replacing columns',
          'Increasing crane capacity',
        ],
        'answer': 0,
      },
      {
        'question': 'Which activity is normally part of finishing work?',
        'options': [
          'Painting',
          'Excavation',
          'Pile driving',
          'Foundation drilling',
        ],
        'answer': 0,
      },
    ],

    'Site Safety': [
      {
        'question': 'Which equipment is important for protecting the head?',
        'options': [
          'Safety helmet',
          'Sandals',
          'Scarf',
          'Watch',
        ],
        'answer': 0,
      },
      {
        'question': 'Which PPE protects the eyes?',
        'options': [
          'Safety goggles',
          'Safety boots',
          'Helmet',
          'Gloves only',
        ],
        'answer': 0,
      },
      {
        'question': 'What should workers use when working at height?',
        'options': [
          'Safety harness',
          'Regular shoes',
          'Umbrella',
          'Notebook',
        ],
        'answer': 0,
      },
      {
        'question': 'Why are warning signs used on construction sites?',
        'options': [
          'To identify hazards',
          'To decorate the site',
          'To advertise products',
          'To store tools',
        ],
        'answer': 0,
      },
      {
        'question': 'Which footwear is appropriate on a construction site?',
        'options': [
          'Safety boots',
          'Slippers',
          'Bare feet',
          'Sandals',
        ],
        'answer': 0,
      },
      {
        'question': 'What should workers do before operating machinery?',
        'options': [
          'Follow safety procedures',
          'Ignore instructions',
          'Remove guards',
          'Run the machine immediately',
        ],
        'answer': 0,
      },
      {
        'question': 'What should be done with a damaged electrical cable?',
        'options': [
          'Report and replace it',
          'Continue using it',
          'Hide it',
          'Touch exposed wires',
        ],
        'answer': 0,
      },
      {
        'question': 'What helps prevent slips and trips?',
        'options': [
          'Keeping work areas clean',
          'Leaving tools everywhere',
          'Blocking walkways',
          'Ignoring spills',
        ],
        'answer': 0,
      },
      {
        'question': 'What should workers do during an emergency?',
        'options': [
          'Follow the emergency procedure',
          'Panic',
          'Ignore alarms',
          'Continue working',
        ],
        'answer': 0,
      },
      {
        'question': 'Who should follow construction site safety rules?',
        'options': [
          'Everyone on site',
          'Only managers',
          'Only visitors',
          'Only engineers',
        ],
        'answer': 0,
      },
    ],

    'Tools & Machinery': [
      {
        'question': 'Which equipment is mainly used to lift heavy materials?',
        'options': [
          'Crane',
          'Hammer',
          'Trowel',
          'Level',
        ],
        'answer': 0,
      },
      {
        'question': 'Which tool is commonly used to drive nails?',
        'options': [
          'Hammer',
          'Trowel',
          'Level',
          'Drill',
        ],
        'answer': 0,
      },
      {
        'question': 'Which tool is used to check horizontal alignment?',
        'options': [
          'Spirit level',
          'Hammer',
          'Saw',
          'Shovel',
        ],
        'answer': 0,
      },
      {
        'question': 'Which machine is commonly used for excavation?',
        'options': [
          'Excavator',
          'Mixer',
          'Crane',
          'Generator',
        ],
        'answer': 0,
      },
      {
        'question': 'Which machine mixes concrete?',
        'options': [
          'Concrete mixer',
          'Excavator',
          'Crane',
          'Compactor',
        ],
        'answer': 0,
      },
      {
        'question': 'Which tool is commonly used to apply mortar?',
        'options': [
          'Trowel',
          'Hammer',
          'Drill',
          'Level',
        ],
        'answer': 0,
      },
      {
        'question': 'Which machine is used to compact soil?',
        'options': [
          'Compactor',
          'Crane',
          'Mixer',
          'Saw',
        ],
        'answer': 0,
      },
      {
        'question': 'Which tool is commonly used to cut wood?',
        'options': [
          'Saw',
          'Level',
          'Trowel',
          'Plumb bob',
        ],
        'answer': 0,
      },
      {
        'question': 'Which machine can be used to transport materials vertically?',
        'options': [
          'Hoist',
          'Hammer',
          'Trowel',
          'Level',
        ],
        'answer': 0,
      },
      {
        'question': 'Which tool can be used to make holes in concrete?',
        'options': [
          'Drill',
          'Trowel',
          'Level',
          'Brush',
        ],
        'answer': 0,
      },
    ],
  };

  void selectAnswer(int answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  Future<void> selectCategory(String category) async {
    setState(() {
      selectedCategory = category;
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
      currentQuestions = [];
      isLoading = true;
    });

    try {
      final firebaseQuestions =
          await _firestoreService.fetchQuizQuestions(category);

      if (firebaseQuestions.isNotEmpty) {
        currentQuestions = firebaseQuestions
            .take(10)
            .map(
              (question) => {
                'question': question.question,
                'options': question.options,
                'answer': question.correctAnswer,
              },
            )
            .toList();
      } else {
        currentQuestions =
            List<Map<String, dynamic>>.from(
          localQuestions[category] ?? [],
        );
      }

      if (currentQuestions.length > 10) {
        currentQuestions = currentQuestions.take(10).toList();
      }
    } catch (e) {
      debugPrint('Quiz loading error: $e');

      currentQuestions =
          List<Map<String, dynamic>>.from(
        localQuestions[category] ?? [],
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  void goBackToCategories() {
    setState(() {
      selectedCategory = null;
      currentQuestions = [];
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
      isLoading = false;
    });
  }

  Future<void> nextQuestion() async {
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer.'),
        ),
      );
      return;
    }

    if (selectedAnswer ==
        currentQuestions[currentQuestion]['answer']) {
      score++;
    }

    if (currentQuestion < currentQuestions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
    } else {
      await showResult();
    }
  }

  Future<void> showResult() async {
    final totalQuestions = currentQuestions.length;

    if (totalQuestions == 0) {
      return;
    }

    final percentage =
        (score / totalQuestions) * 100;

    try {
      await _firestoreService.saveQuizResult(
        category: selectedCategory!,
        score: score,
        totalQuestions: totalQuestions,
      );
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
    }

    if (!mounted) return;

    String message;

    if (percentage >= 80) {
      message = 'Excellent work! 🎉';
    } else if (percentage >= 60) {
      message = 'Good job! Keep learning.';
    } else if (percentage >= 40) {
      message = 'Nice try! You can improve.';
    } else {
      message = 'Keep practicing and try again!';
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Quiz Completed! 🎉',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score / $totalQuestions',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  currentQuestion = 0;
                  score = 0;
                  selectedAnswer = null;
                });
              },
              child: const Text('Try Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  selectedCategory = null;
                  currentQuestions = [];
                  currentQuestion = 0;
                  score = 0;
                  selectedAnswer = null;
                });
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedCategory ?? 'Quiz',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: goBackToCategories,
              )
            : null,
        actions: selectedCategory == null
            ? [
                IconButton(
                  tooltip: 'Quiz History',
                  icon: const Icon(
                    Icons.history_rounded,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const QuizHistoryPage(),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: selectedCategory == null
          ? _buildCategorySelection()
          : _buildQuiz(),
    );
  }

  Widget _buildCategorySelection() {
    const categories = [
      'Materials',
      'Structural',
      'Finishing',
      'Site Safety',
      'Tools & Machinery',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Choose a Category',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select a construction category to start your quiz.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        ...categories.map(
          (category) => Card(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.quiz_outlined,
                ),
              ),
              title: Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
              onTap: isLoading
                  ? null
                  : () => selectCategory(category),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuiz() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (currentQuestions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No questions are available for this category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final question =
        currentQuestions[currentQuestion];

    final options =
        List<String>.from(question['options']);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${currentQuestion + 1} of ${currentQuestions.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value:
                (currentQuestion + 1) /
                    currentQuestions.length,
          ),

          const SizedBox(height: 30),

          Text(
            question['question'].toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];

                final isSelected =
                    selectedAnswer == index;

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    side: isSelected
                        ? BorderSide(
                            color: Colors.orange.shade700,
                            width: 2,
                          )
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        String.fromCharCode(
                          65 + index,
                        ),
                      ),
                    ),
                    title: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                          )
                        : null,
                    selected: isSelected,
                    onTap: () {
                      selectAnswer(index);
                    },
                  ),
                );
              },
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: nextQuestion,
              child: Text(
                currentQuestion ==
                        currentQuestions.length - 1
                    ? 'Finish Quiz'
                    : 'Next Question',
              ),
            ),
          ),
        ],
      ),
    );
  }
}