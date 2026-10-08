import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'quiz_history_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
  });

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
  bool quizFinished = false;
  bool savedSuccessfully = false;
  String? saveError;

  bool isLoading = false;
  bool isSavingResult = false;

  Future<void> startQuiz(
    String category,
  ) async {
    setState(() {
      selectedCategory = category;
      isLoading = true;
      questions = [];
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
      quizFinished = false;
      savedSuccessfully = false;
      saveError = null;
    });

    try {
      final loadedQuestions =
          await _firestoreService.fetchQuizQuestions(category);

      if (!mounted) return;

      if (loadedQuestions.length < 10) {
        setState(() {
          isLoading = false;
          selectedCategory = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$category has only '
              '${loadedQuestions.length} '
              'questions available. '
              '10 questions are required.',
            ),
            duration: const Duration(seconds: 5),
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
        selectedCategory = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load quiz questions.\n$e',
          ),
          duration: const Duration(seconds: 6),
        ),
      );

      debugPrint(
        'Quiz loading error: $e',
      );
    }
  }

  void selectAnswer(
    int answerIndex,
  ) {
    setState(() {
      selectedAnswer = answerIndex;
    });
  }

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

  Future<void> finishQuiz() async {
    setState(() {
      isSavingResult = true;
    });

    bool saved = false;
    String? error;

    try {
      await _firestoreService.saveQuizResult(
        category: selectedCategory!,
        score: score,
        totalQuestions: questions.length,
      );

      saved = true;
    } catch (e) {
      debugPrint(
        'Error saving quiz result: $e',
      );
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      isSavingResult = false;
      quizFinished = true;
      savedSuccessfully = saved;
      saveError = error;
    });
  }

  void restartQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
      quizFinished = false;
      savedSuccessfully = false;
      saveError = null;
    });
  }

  void returnToCategories() {
    setState(() {
      selectedCategory = null;
      questions = [];
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
      quizFinished = false;
      savedSuccessfully = false;
      saveError = null;
    });
  }

  String _performanceMessage(int percentage) {
    if (percentage >= 80) {
      return 'Strong result. You know this category well.';
    }
    if (percentage >= 60) {
      return 'Solid attempt. Review the missed terms and try again.';
    }
    return 'Keep studying this category and retake the quiz when ready.';
  }

  Widget buildCategorySelection() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Choose a category',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Each quiz uses 10 multiple-choice questions from Firestore.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        ...categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radius),
                onTap: () => startQuiz(category),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconBadge(icon: iconForCategory(category)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              descriptionForCategory(category),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '10 questions',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildQuiz() {
    final question = questions[currentQuestion];
    final progress = (currentQuestion + 1) / questions.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedCategory ?? 'Quiz',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Question ${currentQuestion + 1} of ${questions.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.orangeSoft,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            question.question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final isSelected = selectedAnswer == index;
                final letter = String.fromCharCode(65 + index);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.orangeSoft
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.orange
                            : AppColors.border,
                        width: isSelected ? 1.6 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? AppColors.orange
                            : AppColors.orangeSoft,
                        foregroundColor: isSelected
                            ? Colors.white
                            : AppColors.orangeDark,
                        child: Text(letter),
                      ),
                      title: Text(
                        question.options[index],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.orange,
                            )
                          : null,
                      onTap: () => selectAnswer(index),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSavingResult ? null : nextQuestion,
              child: isSavingResult
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      currentQuestion == questions.length - 1
                          ? 'Finish quiz'
                          : 'Next question',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResult() {
    final totalQuestions = questions.length;
    final percentage = totalQuestions == 0
        ? 0
        : ((score / totalQuestions) * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  const IconBadge(icon: Icons.emoji_events_outlined),
                  const SizedBox(height: 16),
                  Text(
                    'Quiz complete',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedCategory ?? 'Quiz',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '$score / $totalQuestions',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orangeDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _performanceMessage(percentage),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    savedSuccessfully
                        ? 'Your result has been saved to quiz history.'
                        : 'Your result could not be saved. ${saveError ?? 'Please check Firebase permissions.'}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: restartQuiz,
            child: const Text('Try again'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: returnToCategories,
            child: const Text('Choose another category'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizHistoryPage(),
                ),
              );
            },
            child: const Text('View history and progress'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction quiz'),
        actions: [
          IconButton(
            tooltip: 'Quiz history',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizHistoryPage(),
                ),
              );
            },
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: isLoading
          ? const AppLoadingState(message: 'Loading quiz questions...')
          : quizFinished
              ? buildResult()
              : questions.isEmpty
                  ? buildCategorySelection()
                  : buildQuiz(),
    );
  }
}
