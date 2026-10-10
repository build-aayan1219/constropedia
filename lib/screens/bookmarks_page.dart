import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_widget.dart';
import 'article_page.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Saved Bookmarks',
        subtitle: 'Personal Construction Reading List',
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getBookmarks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: 3,
              itemBuilder: (context, index) => const ArticleCardSkeleton(),
            );
          }

          if (snapshot.hasError) {
            return ErrorStateWidget(
              message:
                  'Unable to load your saved bookmarks. Please check your network connection.',
            );
          }

          final bookmarks = snapshot.data ?? [];

          if (bookmarks.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.bookmark_border_rounded,
              title: 'No Bookmarks Yet',
              message:
                  'Save useful articles and technical construction references to quickly access them here anytime.',
              buttonLabel: 'Explore Encyclopedia',
              onButtonPressed: () {
                Navigator.pop(context);
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];

              final Article article = Article(
                id: _stringValue(
                  bookmark['articleId'] ?? bookmark['id'],
                ),
                title: _stringValue(
                  bookmark['title'],
                ),
                description: _stringValue(
                  bookmark['description'],
                ),
                content: _stringValue(
                  bookmark['content'],
                ),
                category: _stringValue(
                  bookmark['category'],
                ),
                imageUrl: _nullableString(
                  bookmark['imageUrl'],
                ),
                createdAt: bookmark['createdAt'],
              );

              return ArticleCard(
                article: article,
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticlePage(
                        article: article,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }
    return text;
  }
}