import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';

class QuizHistoryPage extends StatelessWidget {
  const QuizHistoryPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Quiz Performance',
        subtitle: 'Evaluation History & Test Results',
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getQuizHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2.8,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Loading quiz records...',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return ErrorStateWidget(
              message:
                  'Unable to load your quiz history. Error: ${snapshot.error}',
            );
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.history_rounded,
              title: 'No Quiz Attempts Yet',
              message:
                  'Complete a construction quiz to assess your knowledge and track your test scores here.',
              buttonLabel: 'Take a Quiz',
              onButtonPressed: () {
                Navigator.pop(context);
              },
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            itemCount: history.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final attempt = history[index];
              final category =
                  attempt['category']?.toString() ?? 'Construction Quiz';
              final score = (attempt['score'] as num?)?.toInt() ?? 0;
              final totalQuestions =
                  (attempt['totalQuestions'] as num?)?.toInt() ?? 0;
              final percentage =
                  (attempt['percentage'] as num?)?.toDouble() ?? 0;
              final isPassed = percentage >= 60;

              return Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPassed
                            ? AppColors.successLight
                            : AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isPassed
                              ? AppColors.success.withValues(alpha: 0.3)
                              : AppColors.primaryBorder.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        size: 26,
                        color: isPassed ? AppColors.success : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
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
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Score: $score of $totalQuestions',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isPassed ? 'Passed' : 'Needs Review',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isPassed
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPassed
                            ? AppColors.successLight
                            : AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isPassed
                              ? AppColors.success
                              : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}