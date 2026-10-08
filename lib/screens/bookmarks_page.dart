import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/firestore_service.dart';
import '../widgets/app_ui.dart';
import 'article_page.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final FirestoreService _firestoreService = FirestoreService();
  int _streamGeneration = 0;

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

  Article _articleFromBookmark(Map<String, dynamic> bookmark) {
    return Article(
      id: _stringValue(bookmark['articleId'] ?? bookmark['id']),
      title: _stringValue(bookmark['title']),
      description: _stringValue(bookmark['description']),
      content: _stringValue(bookmark['content']),
      category: _stringValue(bookmark['category']),
      imageUrl: _nullableString(bookmark['imageUrl']),
      createdAt: bookmark['createdAt'],
    );
  }

  Future<void> _removeBookmark(Article article) async {
    try {
      await _firestoreService.removeBookmark(
        articleId: article.id,
        title: article.title,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from bookmarks')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to remove bookmark: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        key: ValueKey(_streamGeneration),
        stream: _firestoreService.getBookmarks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingState(message: 'Loading bookmarks...');
          }

          if (snapshot.hasError) {
            return AppErrorState(
              title: 'Unable to load bookmarks',
              details: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _streamGeneration++;
                });
              },
            );
          }

          final bookmarks = snapshot.data ?? [];

          if (bookmarks.isEmpty) {
            return const AppEmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No bookmarks yet',
              message: 'Save articles you want to revisit from any term page.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: bookmarks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final article = _articleFromBookmark(bookmarks[index]);

              return Dismissible(
                key: ValueKey(article.title),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4D6D4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete_outline_rounded),
                ),
                confirmDismiss: (_) async {
                  await _removeBookmark(article);
                  return false;
                },
                child: ArticleListCard(
                  article: article,
                  leadingIcon: Icons.bookmark_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticlePage(article: article),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
