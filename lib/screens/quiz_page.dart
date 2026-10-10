import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/primary_button.dart';
import 'quiz_history_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final FirestoreService _firestoreService = FirestoreService();

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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Materials':
        return Icons.construction_rounded;
      case 'Structural':
        return Icons.account_tree_rounded;
      case 'Finishing':
        return Icons.format_paint_rounded;
      case 'Site Safety':
        return Icons.health_and_safety_rounded;
      case 'Tools & Machinery':
        return Icons.engineering_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }

  // ==================================================
  // START QUIZ
  // ==================================================

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
          await _firestoreService.fetchQuizQuestions(category);

      if (!mounted) return;

      if (loadedQuestions.isEmpty) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No questions available for $category yet.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        questions = loadedQuestions.take(10).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load quiz questions: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==================================================
  // SELECT ANSWER
  // ==================================================

  void selectAnswer(int answerIndex) {
    setState(() {
      selectedAnswer = answerIndex;
    });
  }

  // ==================================================
  // NEXT QUESTION
  // ==================================================

  Future<void> nextQuestion() async {
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Please select an option before proceeding.'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final question = questions[currentQuestion];
    final selectedOption = question.options[selectedAnswer!];

    if (selectedOption == question.correctAnswer) {
      score++;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
      return;
    }

    await finishQuiz();
  }

  // ==================================================
  // FINISH QUIZ
  // ==================================================

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
      debugPrint('Error saving quiz result: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quiz finished, but score could not be saved to cloud: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      isSavingResult = false;
    });

    showResult(savedSuccessfully: savedSuccessfully);
  }

  // ==================================================
  // RESULT DIALOG
  // ==================================================

  void showResult({required bool savedSuccessfully}) {
    final totalQuestions = questions.length;
    final percentage = totalQuestions == 0
        ? 0
        : ((score / totalQuestions) * 100).round();
    final wrongAnswers = totalQuestions - score;
    final isPassed = percentage >= 60;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isPassed ? AppColors.successLight : AppColors.primarySubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPassed ? Icons.emoji_events_rounded : Icons.psychology_rounded,
                  size: 48,
                  color: isPassed ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quiz Completed 🎉',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$selectedCategory Quiz',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // SCORE CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score / $totalQuestions',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$percentage% Score',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 16, color: AppColors.success),
                            const SizedBox(width: 6),
                            Text(
                              'Correct: $score',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.cancel_rounded,
                                size: 16, color: AppColors.error),
                            const SizedBox(width: 6),
                            Text(
                              'Wrong: $wrongAnswers',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (savedSuccessfully)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_done_rounded,
                        size: 15, color: AppColors.success),
                    SizedBox(width: 6),
                    Text(
                      'Saved to your Quiz History',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      restartQuiz();
                    },
                    child: const Text('Try Again'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
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
                    child: const Text('All Quizzes'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void restartQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
    });
  }

  // ==================================================
  // CATEGORY SCREEN
  // ==================================================

  Widget buildCategorySelection() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        // PROMO CARD
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primaryBorder.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assess Your Knowledge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Select any topic to test your civil engineering concepts with 10 questions.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Select a Quiz Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),

        const SizedBox(height: 12),

        ...categories.map(
          (category) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => startQuiz(category),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primarySubtle,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primaryBorder.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Icon(
                            _getCategoryIcon(category),
                            size: 26,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                '10 Questions • Multiple Choice',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Start',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==================================================
  // ACTIVE QUIZ SCREEN
  // ==================================================

  Widget buildQuiz() {
    final question = questions[currentQuestion];
    final progress = (currentQuestion + 1) / questions.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PROGRESS & HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryBorder.withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  selectedCategory ?? 'Quiz',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Text(
                'Question ${currentQuestion + 1} of ${questions.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),

          const SizedBox(height: 24),

          // QUESTION CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              question.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.45,
                letterSpacing: -0.2,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // OPTIONS LIST
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final isSelected = selectedAnswer == index;
                final optionLetter = String.fromCharCode(65 + index);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primarySubtle : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => selectAnswer(index),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceMuted,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  optionLetter,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          PrimaryButton(
            label: currentQuestion == questions.length - 1
                ? 'Finish Quiz'
                : 'Next Question',
            icon: currentQuestion == questions.length - 1
                ? Icons.done_all_rounded
                : Icons.arrow_forward_rounded,
            isLoading: isSavingResult,
            onPressed: isSavingResult ? null : nextQuestion,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Construction Quiz',
        subtitle: selectedCategory ?? 'Test Your Engineering Knowledge',
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizHistoryPage(),
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
            tooltip: 'View Quiz History',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2.8,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Loading quiz questions...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : questions.isEmpty
              ? buildCategorySelection()
              : buildQuiz(),
    );
  }
}