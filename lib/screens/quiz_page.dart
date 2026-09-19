import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import '../services/firestore_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final FirestoreService _firestoreService =
      FirestoreService();

  final List<String> categories = const [
    'Materials',
    'Structural',
    'Finishing',
    'Site Safety',
    'Tools & Machinery',
  ];

  String? selectedCategory;

  List<QuizQuestionModel> questions = [];

  int currentQuestion = 0;
  int score = 0;
  int? selectedAnswer;

  bool isLoading = false;
  bool isSavingResult = false;

  // --------------------------------------------------
  // CATEGORY SELECTION
  // --------------------------------------------------

  Future<void> startQuiz(String category) async {
    setState(() {
      selectedCategory = category;
      isLoading = true;
      questions = [];
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
    });

    try {
      final loadedQuestions =
          await _firestoreService.fetchQuizQuestions(
        category,
      );

      if (!mounted) return;

      if (loadedQuestions.isEmpty) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No quiz questions found for $category.',
            ),
          ),
        );

        return;
      }

      // Keep maximum of 10 questions.
      final quizQuestions =
          loadedQuestions.length > 10
              ? loadedQuestions.take(10).toList()
              : loadedQuestions;

      setState(() {
        questions = quizQuestions;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load quiz questions.\n$e',
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      debugPrint(
        'Quiz loading error: $e',
      );
    }
  }

  // --------------------------------------------------
  // ANSWER SELECTION
  // --------------------------------------------------

  void selectAnswer(int answerIndex) {
    setState(() {
      selectedAnswer = answerIndex;
    });
  }

  // --------------------------------------------------
  // NEXT QUESTION
  // --------------------------------------------------

  Future<void> nextQuestion() async {
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select an answer.',
          ),
        ),
      );

      return;
    }

    final correctAnswer =
        questions[currentQuestion].correctAnswer;

    if (selectedAnswer == correctAnswer) {
      score++;
    }

    if (currentQuestion <
        questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });

      return;
    }

    await finishQuiz();
  }

  // --------------------------------------------------
  // FINISH QUIZ
  // --------------------------------------------------

  Future<void> finishQuiz() async {
    setState(() {
      isSavingResult = true;
    });

    bool savedSuccessfully = false;

    try {
      await _firestoreService.saveQuizResult(
        category: selectedCategory!,
        score: score,
        totalQuestions: questions.length,
      );

      savedSuccessfully = true;
    } catch (e) {
      debugPrint(
        'Error saving quiz result: $e',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quiz completed, but the result could not be saved.\n$e',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      isSavingResult = false;
    });

    showResult(
      savedSuccessfully: savedSuccessfully,
    );
  }

  // --------------------------------------------------
  // RESULT
  // --------------------------------------------------

  void showResult({
    required bool savedSuccessfully,
  }) {
    final totalQuestions = questions.length;

    final percentage = totalQuestions == 0
        ? 0
        : ((score / totalQuestions) * 100).round();

    showDialog(
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
                '$percentage%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                savedSuccessfully
                    ? 'Your result has been saved to Quiz History.'
                    : 'Your result could not be saved. Please check Firebase permissions.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                restartQuiz();
              },
              child: const Text(
                'Try Again',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  selectedCategory = null;
                  questions = [];
                  currentQuestion = 0;
                  score = 0;
                  selectedAnswer = null;
                });
              },
              child: const Text(
                'Done',
              ),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // RESTART
  // --------------------------------------------------

  void restartQuiz() {
    if (selectedCategory == null) {
      return;
    }

    setState(() {
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
    });
  }

  // --------------------------------------------------
  // CATEGORY SCREEN
  // --------------------------------------------------

  Widget buildCategorySelection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),

        const Text(
          'Choose a Category',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Test your construction knowledge.',
          style: TextStyle(
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 24),

        ...categories.map(
          (category) {
            return Card(
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  child: const Icon(
                    Icons.construction_rounded,
                  ),
                ),
                title: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                ),
                onTap: () {
                  startQuiz(category);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // --------------------------------------------------
  // QUIZ SCREEN
  // --------------------------------------------------

  Widget buildQuiz() {
    final question =
        questions[currentQuestion];

    final options = question.options;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${currentQuestion + 1} of ${questions.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value:
                (currentQuestion + 1) /
                    questions.length,
          ),

          const SizedBox(height: 30),

          Text(
            question.question,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (
                context,
                index,
              ) {
                final isSelected =
                    selectedAnswer == index;

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
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
                      options[index],
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

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSavingResult
                  ? null
                  : nextQuestion,
              child: isSavingResult
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      currentQuestion ==
                              questions.length - 1
                          ? 'Finish Quiz'
                          : 'Next Question',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Construction Quiz',
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : questions.isEmpty
              ? buildCategorySelection()
              : buildQuiz(),
    );
  }
}