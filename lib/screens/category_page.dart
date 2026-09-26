import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import 'article_page.dart';

class CategoryPage extends StatelessWidget {
  final String categoryName;

  const CategoryPage({
    super.key,
    required this.categoryName,
  });

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase().trim();
    if (cat.contains('material')) return Icons.construction_rounded;
    if (cat.contains('structur')) return Icons.account_tree_rounded;
    if (cat.contains('finish')) return Icons.format_paint_rounded;
    if (cat.contains('safety')) return Icons.health_and_safety_rounded;
    if (cat.contains('tool') || cat.contains('machin')) {
      return Icons.engineering_rounded;
    }
    return Icons.menu_book_rounded;
  }

  String _getCategoryDescription(String category) {
    final cat = category.toLowerCase().trim();
    if (cat.contains('material')) {
      return 'Core building materials, cements, masonry, composites, and reinforcements.';
    }
    if (cat.contains('structur')) {
      return 'Load-bearing elements, foundations, columns, beams, slabs, and frameworks.';
    }
    if (cat.contains('finish')) {
      return 'Architectural coatings, plasters, tiles, screeds, and interior finishes.';
    }
    if (cat.contains('safety')) {
      return 'On-site protocols, personal protective equipment (PPE), and hazard prevention.';
    }
    if (cat.contains('tool') || cat.contains('machin')) {
      return 'Construction machinery, surveying instruments, mixing plants, and power tools.';
    }
    return 'Comprehensive construction reference material and technical guidance.';
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: categoryName,
        subtitle: 'Construction Encyclopedia',
      ),
      body: StreamBuilder<List<Article>>(
        stream: firestoreService.getArticlesByCategory(categoryName),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: 4,
              itemBuilder: (context, index) => const ArticleCardSkeleton(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return ErrorStateWidget(
              message:
                  'We were unable to load articles for $categoryName. Please check your internet connection.',
            );
          }

          final articles = snapshot.data ?? [];

          // Empty category
          if (articles.isEmpty) {
            return EmptyStateWidget(
              icon: _getCategoryIcon(categoryName),
              title: 'No Articles in $categoryName',
              message:
                  'There are currently no articles indexed under this category. Please check back later or explore other categories.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              // CATEGORY HEADER HERO
              Container(
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.only(bottom: 18),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primaryBorder.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        _getCategoryIcon(categoryName),
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                categoryName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${articles.length} Topics',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getCategoryDescription(categoryName),
                            style: const TextStyle(
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

              // ARTICLES LIST
              ...articles.map(
                (article) => ArticleCard(
                  article: article,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticlePage(article: article),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}