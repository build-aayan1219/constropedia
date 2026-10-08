import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/firestore_service.dart';
import '../widgets/app_ui.dart';
import 'article_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  List<Article> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadArticles();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final articles = await _firestoreService.getArticles();

      if (!mounted) return;

      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      debugPrint('Search article loading error: $e');
    }
  }

  List<Article> get _filteredArticles {
    if (_searchQuery.isEmpty) {
      return _articles;
    }

    return _articles.where((article) {
      final title = article.title.toLowerCase();
      final description = article.description.toLowerCase();
      final content = article.content.toLowerCase();
      final category = article.category.toLowerCase();

      return title.contains(_searchQuery) ||
          description.contains(_searchQuery) ||
          content.contains(_searchQuery) ||
          category.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredArticles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search construction terms...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (!_isLoading && _errorMessage == null && results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _searchQuery.isEmpty
                      ? '${results.length} terms'
                      : '${results.length} results',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          Expanded(
            child: _buildBody(results),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<Article> results) {
    if (_isLoading) {
      return const AppLoadingState(message: 'Searching the library...');
    }

    if (_errorMessage != null) {
      return AppErrorState(
        title: 'Unable to load articles',
        details: _errorMessage ?? 'Unknown error',
        onRetry: _loadArticles,
      );
    }

    if (results.isEmpty) {
      final hasSearchText = _searchQuery.isNotEmpty;
      return AppEmptyState(
        icon: hasSearchText
            ? Icons.search_off_rounded
            : Icons.menu_book_outlined,
        title: hasSearchText ? 'No articles found' : 'No articles available',
        message: hasSearchText
            ? 'Try another construction term or category name.'
            : 'There are no articles available right now.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final article = results[index];
        return ArticleListCard(
          article: article,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticlePage(article: article),
              ),
            );
          },
        );
      },
    );
  }
}
