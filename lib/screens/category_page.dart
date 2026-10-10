import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/firestore_service.dart';
import '../widgets/app_ui.dart';
import 'article_page.dart';

class CategoryPage extends StatelessWidget {
  final String categoryName;

  const CategoryPage({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: FutureBuilder<List<Article>>(
        future: firestoreService.getArticlesByCategory(categoryName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingState(message: 'Loading articles...');
          }

          if (snapshot.hasError) {
            return AppErrorState(
              title: 'Unable to load articles',
              details: '${snapshot.error}',
            );
          }

          final articles = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: AppSectionHeader(
                  title: categoryName,
                  subtitle:
                      '${descriptionForCategory(categoryName)} ${articles.length} ${articles.length == 1 ? 'term' : 'terms'}.',
                ),
              ),
              Expanded(
                child: articles.isEmpty
                    ? AppEmptyState(
                        icon: Icons.menu_book_outlined,
                        title: 'No articles yet',
                        message:
                            'There are no articles in $categoryName yet.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: articles.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final article = articles[index];
                          return ArticleListCard(
                            article: article,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArticlePage(
                                    article: article,
                                  ),
                                ),
                              );
                            },
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
