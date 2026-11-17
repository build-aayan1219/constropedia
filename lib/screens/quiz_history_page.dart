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

  Map<String, List<int>> _scoresByCategory(List<Map<String, dynamic>> history) {
    final map = <String, List<int>>{};
    for (final attempt in history) {
      final category = attempt['category']?.toString() ?? 'Quiz';
      final percentage = (attempt['percentage'] as num?)?.toInt() ?? 0;
      map.putIfAbsent(category, () => []).add(percentage);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Learning progress')),
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
                  'Complete a category quiz and your scores, statistics, and progress will appear here.',
              actionLabel: 'Start a quiz',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizPage()),
                );
              },
            );
          }

          // Compute verified real metrics
          final totalQuizzes = history.length;
          int totalPercentageSum = 0;
          int bestOverall = 0;

          for (final attempt in history) {
            final pct = (attempt['percentage'] as num?)?.toInt() ?? 0;
            totalPercentageSum += pct;
            if (pct > bestOverall) {
              bestOverall = pct;
            }
          }

          final averageScore = (totalPercentageSum / totalQuizzes).round();
          final best = _bestScores(history);
          final categoryScores = _scoresByCategory(history);

          // Identify weak categories (average < 60%)
          final weakCategories = <String>[];
          categoryScores.forEach((cat, scores) {
            final avg = scores.reduce((a, b) => a + b) / scores.length;
            if (avg < 60) {
              weakCategories.add(cat);
            }
          });

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const AppSectionHeader(
                title: 'Overview',
                subtitle: 'Key statistics across all your quiz attempts.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Total Quizzes',
                      value: '$totalQuizzes',
                      icon: Icons.quiz_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Avg Score',
                      value: '$averageScore%',
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Best Score',
                      value: '$bestOverall%',
                      icon: Icons.emoji_events_outlined,
                    ),
                  ),
                ],
              ),
              if (weakCategories.isNotEmpty) ...[
                const SizedBox(height: 20),
                Card(
                  color: AppColors.orangeSoft.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.orangeDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recommended for review',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.orangeDark,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Average below 60% in: ${weakCategories.join(', ')}. Try reading their articles and retrying the quiz!',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const AppSectionHeader(
                title: 'Category performance',
                subtitle: 'Your highest recorded score per category.',
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
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
                title: 'Recent activity',
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
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

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.orange),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
