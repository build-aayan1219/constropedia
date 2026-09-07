import 'package:flutter/material.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String? selectedCategory;

  int currentQuestion = 0;
  int score = 0;
  int? selectedAnswer;

  final Map<String, List<QuizQuestion>> quizData = {
    'Materials': [
      QuizQuestion(
        question:
            'Which material is commonly used as a binding agent in concrete?',
        options: ['Cement', 'Sand', 'Gravel', 'Steel'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question:
            'Which material is mainly used as fine aggregate in concrete?',
        options: ['Steel', 'Sand', 'Cement', 'Brick'],
        correctAnswer: 1,
      ),
      QuizQuestion(
        question: 'Which of the following is a coarse aggregate?',
        options: ['Sand', 'Cement', 'Gravel', 'Water'],
        correctAnswer: 2,
      ),
      QuizQuestion(
        question: 'What is the main raw material used to manufacture cement?',
        options: ['Limestone', 'Wood', 'Plastic', 'Glass'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which material is commonly used for reinforcement in concrete?',
        options: ['Timber', 'Steel', 'Brick', 'Glass'],
        correctAnswer: 1,
      ),
      QuizQuestion(
        question: 'What is brick primarily made from?',
        options: ['Clay', 'Steel', 'Cement only', 'Aluminium'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which material is known for its high compressive strength?',
        options: ['Concrete', 'Rubber', 'Plastic', 'Fabric'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which material is commonly used for waterproofing roofs?',
        options: ['Bitumen', 'Sand', 'Gravel', 'Brick'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which material is commonly used for electrical wiring?',
        options: ['Copper', 'Concrete', 'Brick', 'Cement'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which material is generally used for glass manufacturing?',
        options: ['Sand', 'Steel', 'Cement', 'Timber'],
        correctAnswer: 0,
      ),
    ],

    'Structural': [
      QuizQuestion(
        question: 'Which structural element primarily carries vertical loads?',
        options: ['Column', 'Window', 'Door', 'Paint'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which element transfers loads from slabs to columns?',
        options: ['Beam', 'Door', 'Wall paint', 'Window'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What is the main purpose of a foundation?',
        options: [
          'Support the structure',
          'Decorate the building',
          'Provide lighting',
          'Reduce painting cost',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which structural member is mainly subjected to bending?',
        options: ['Beam', 'Column', 'Foundation soil', 'Door'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What does RCC stand for?',
        options: [
          'Reinforced Cement Concrete',
          'Rapid Construction Concrete',
          'Ready Cement Construction',
          'Reinforced Clay Concrete',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which structure is commonly used to span an opening?',
        options: ['Beam', 'Foundation', 'Footing', 'Column base'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What is a slab mainly used for?',
        options: [
          'Floor or roof',
          'Painting walls',
          'Water storage only',
          'Electrical wiring',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which force tends to pull a structural member apart?',
        options: ['Tension', 'Compression', 'Shear', 'Torsion'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which force tends to push a member together?',
        options: ['Compression', 'Tension', 'Bending', 'Torsion'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What is the purpose of reinforcement in RCC?',
        options: [
          'To resist tensile forces',
          'To reduce concrete weight',
          'To replace cement',
          'To improve paint quality',
        ],
        correctAnswer: 0,
      ),
    ],

    'Finishing': [
      QuizQuestion(
        question: 'What is plastering mainly used for?',
        options: [
          'Finishing wall surfaces',
          'Making foundations',
          'Installing wiring',
          'Making steel',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which material is commonly used for wall painting?',
        options: ['Paint', 'Gravel', 'Steel', 'Cement blocks'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What is tiling commonly used for?',
        options: [
          'Floor and wall finishing',
          'Structural reinforcement',
          'Foundation construction',
          'Concrete mixing',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What is putty generally used for?',
        options: [
          'Smoothing wall surfaces',
          'Making concrete',
          'Reinforcing columns',
          'Making foundations',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which tool is commonly used for applying plaster?',
        options: ['Trowel', 'Hammer drill', 'Wrench', 'Saw'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What is waterproofing intended to prevent?',
        options: [
          'Water penetration',
          'Concrete strength',
          'Steel corrosion only',
          'Wall painting',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which finish is commonly applied to wooden surfaces?',
        options: ['Varnish', 'Concrete', 'Gravel', 'Cement slurry'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What is grouting commonly used for?',
        options: [
          'Filling joints or gaps',
          'Painting walls',
          'Cutting steel',
          'Making bricks',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which flooring material is commonly used in buildings?',
        options: ['Ceramic tile', 'Rebar', 'Cement bag', 'Timber formwork'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What should generally be done before painting a wall?',
        options: [
          'Prepare and clean the surface',
          'Remove the foundation',
          'Cut the reinforcement',
          'Break the wall',
        ],
        correctAnswer: 0,
      ),
    ],

    'Site Safety': [
      QuizQuestion(
        question: 'What does PPE stand for?',
        options: [
          'Personal Protective Equipment',
          'Public Protection Equipment',
          'Personal Project Equipment',
          'Professional Protection Engine',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which PPE protects the head?',
        options: ['Safety helmet', 'Safety shoes', 'Gloves', 'Goggles'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which PPE protects the eyes?',
        options: ['Safety goggles', 'Helmet', 'Safety shoes', 'Ear plugs'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Why are safety shoes used on construction sites?',
        options: [
          'To protect feet',
          'To protect eyes',
          'To protect ears',
          'To protect the head',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What should be used when working at height?',
        options: [
          'Safety harness',
          'Paint brush',
          'Measuring tape',
          'Trowel',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What is a safety barricade used for?',
        options: [
          'Restricting access to hazardous areas',
          'Mixing concrete',
          'Painting walls',
          'Measuring buildings',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question:
            'What should workers do before operating unfamiliar equipment?',
        options: [
          'Receive proper training',
          'Operate it immediately',
          'Remove safety guards',
          'Ignore instructions',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What is an important action during a fire emergency?',
        options: [
          'Follow the emergency procedure',
          'Hide inside the building',
          'Ignore the alarm',
          'Continue working',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Why should construction sites be kept clean?',
        options: [
          'To reduce accidents',
          'To increase noise',
          'To increase waste',
          'To slow down work',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What should be done with damaged electrical cables?',
        options: [
          'Report and replace them',
          'Continue using them',
          'Cover them with paper',
          'Ignore the damage',
        ],
        correctAnswer: 0,
      ),
    ],

    'Tools & Machinery': [
      QuizQuestion(
        question: 'Which tool is commonly used to drive nails?',
        options: ['Hammer', 'Trowel', 'Level', 'Shovel'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which tool is used to measure length?',
        options: ['Measuring tape', 'Hammer', 'Chisel', 'Trowel'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question:
            'Which tool is used to check whether a surface is horizontal?',
        options: ['Spirit level', 'Hammer', 'Saw', 'Drill'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which machine is commonly used to mix concrete?',
        options: [
          'Concrete mixer',
          'Excavator',
          'Crane',
          'Bulldozer',
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which machine is commonly used for excavation?',
        options: ['Excavator', 'Concrete mixer', 'Generator', 'Compactor'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which machine is used to lift heavy materials?',
        options: ['Crane', 'Trowel', 'Hammer', 'Wheelbarrow'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which tool is commonly used to cut wood?',
        options: ['Saw', 'Level', 'Trowel', 'Wrench'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which tool is used for tightening nuts and bolts?',
        options: ['Wrench', 'Hammer', 'Saw', 'Trowel'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which equipment is commonly used to compact soil?',
        options: ['Compactor', 'Crane', 'Concrete mixer', 'Drill'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question:
            'Which machine is used to generate electrical power at a construction site?',
        options: ['Generator', 'Excavator', 'Crane', 'Mixer'],
        correctAnswer: 0,
      ),
    ],
  };

  final Map<String, IconData> categoryIcons = {
    'Materials': Icons.inventory_2_outlined,
    'Structural': Icons.account_tree_outlined,
    'Finishing': Icons.format_paint_outlined,
    'Site Safety': Icons.health_and_safety_outlined,
    'Tools & Machinery': Icons.construction_outlined,
  };

  List<QuizQuestion> get currentQuestions {
    if (selectedCategory == null) {
      return [];
    }

    return quizData[selectedCategory] ?? [];
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
    });
  }

  void selectAnswer(int index) {
    // User can change their answer before moving to the next question.
    setState(() {
      selectedAnswer = index;
    });
  }

  void nextQuestion() {
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer first.'),
        ),
      );
      return;
    }

    // Calculate score only when moving to the next question.
    if (selectedAnswer == currentQuestions[currentQuestion].correctAnswer) {
      score++;
    }

    if (currentQuestion < currentQuestions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
    } else {
      showResult();
    }
  }

  void showResult() {
    final totalQuestions = currentQuestions.length;
    final percentage = (score / totalQuestions) * 100;

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              'Quiz Completed!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                size: 60,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                '$score / $totalQuestions',
                style: const TextStyle(
                  fontSize: 32,
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
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

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
                Navigator.pop(context);

                setState(() {
                  selectedCategory = null;
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

  void goBackToCategories() {
    setState(() {
      selectedCategory = null;
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
    });
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
      ),
      body: selectedCategory == null
          ? _buildCategorySelection()
          : _buildQuiz(),
    );
  }

  Widget _buildCategorySelection() {
    final categories = quizData.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Test Your Knowledge',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a category to start your quiz.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          ...categories.map(
            (category) => _buildCategoryCard(category),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => selectCategory(category),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  categoryIcons[category],
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    final question = currentQuestions[currentQuestion];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${currentQuestion + 1} of ${currentQuestions.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value:
                  (currentQuestion + 1) / currentQuestions.length,
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                question.question,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Choose the correct answer',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          ...List.generate(
            question.options.length,
            (index) => _buildOption(
              index,
              question.options[index],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                currentQuestion == currentQuestions.length - 1
                    ? 'Finish Quiz'
                    : 'Next Question',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOption(int index, String option) {
    final isSelected = selectedAnswer == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => selectAnswer(index),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              width: 1.5,
              color: isSelected
                  ? Colors.orange
                  : Colors.grey.shade300,
            ),
            color: isSelected
                ? Colors.orange.shade50
                : Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.orange
                      : Colors.grey.shade200,
                ),
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.orange,
                ),
            ],
          ),
        ),
      ),
    );
  }
}