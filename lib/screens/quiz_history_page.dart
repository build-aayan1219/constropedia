import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'quiz_page.dart';

class QuizHistoryPage extends StatelessWidget {
  const QuizHistoryPage({super.key});

  String _formatDate(dynamic value) {
    DateTime? date;
    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date == null) {
      return 'Date unavailable';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Map<String, int> _bestScores(List<Map<String, dynamic>> history) {
    final best = <String, int>{};
    for (final attempt in history) {
      final category = attempt['category']?.toString() ?? 'Quiz';
      final percentage = (attempt['percentage'] as num?)?.toInt() ?? 0;
      final previous = best[category] ?? 0;
      if (percentage > previous) {
        best[category] = percentage;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getQuizHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingState(message: 'Loading quiz history...');
          }

          if (snapshot.hasError) {
            return AppErrorState(
              title: 'Unable to load quiz history',
              details: '${snapshot.error}',
            );
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return AppEmptyState(
              icon: Icons.history_rounded,
              title: 'No quiz history yet',
              message:
                  'Complete a category quiz and your scores will appear here.',
              actionLabel: 'Start a quiz',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizPage(),
                  ),
                );
              },
            );
          }

          final best = _bestScores(history);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              AppSectionHeader(
                title: 'Learning progress',
                subtitle:
                    '${history.length} completed ${history.length == 1 ? 'quiz' : 'quizzes'} from your history.',
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: best.entries.map((entry) {
                      final value = (entry.value.clamp(0, 100)) / 100;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Text(
                                  '${entry.value}% best',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                backgroundColor: AppColors.orangeSoft,
                                color: AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const AppSectionHeader(
                title: 'Quiz history',
                subtitle: 'Most recent attempts first.',
              ),
              const SizedBox(height: 12),
              ...history.map((attempt) {
                final category = attempt['category']?.toString() ?? 'Quiz';
                final score = (attempt['score'] as num?)?.toInt() ?? 0;
                final totalQuestions =
                    (attempt['totalQuestions'] as num?)?.toInt() ?? 0;
                final percentage =
                    (attempt['percentage'] as num?)?.toDouble() ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Score $score / $totalQuestions',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(attempt['completedAt']),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.orangeDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
