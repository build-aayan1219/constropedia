import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/firestore_service.dart';
import 'article_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController =
      TextEditingController();

  final FirestoreService firestoreService = FirestoreService();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void performSearch(String value) {
    setState(() {
      searchText = value.trim().toLowerCase();
    });
  }

  List<Article> filterArticles(List<Article> articles) {
    if (searchText.isEmpty) {
      return articles;
    }

    final results = articles.where((article) {
      final title = article.title.toLowerCase();
      final description = article.description.toLowerCase();
      final content = article.content.toLowerCase();
      final category = article.category.toLowerCase();

      return title.contains(searchText) ||
          description.contains(searchText) ||
          content.contains(searchText) ||
          category.contains(searchText);
    }).toList();

    // Exact title matches first.
    results.sort((a, b) {
      final aTitle = a.title.toLowerCase();
      final bTitle = b.title.toLowerCase();

      final aExact = aTitle == searchText;
      final bExact = bTitle == searchText;

      if (aExact && !bExact) {
        return -1;
      }

      if (!aExact && bExact) {
        return 1;
      }

      final aStarts = aTitle.startsWith(searchText);
      final bStarts = bTitle.startsWith(searchText);

      if (aStarts && !bStarts) {
        return -1;
      }

      if (!aStarts && bStarts) {
        return 1;
      }

      return aTitle.compareTo(bTitle);
    });

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Articles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              10,
            ),
            child: TextField(
              controller: searchController,
              onChanged: performSearch,
              decoration: InputDecoration(
                hintText: 'Search construction terms...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          searchController.clear();

                          setState(() {
                            searchText = '';
                          });
                        },
                        icon: const Icon(
                          Icons.clear_rounded,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.orange.shade700,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Article>>(
              stream: firestoreService.getArticles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState(
                    snapshot.error.toString(),
                  );
                }

                final articles = snapshot.data ?? [];
                final searchResults = filterArticles(articles);

                if (searchResults.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    6,
                    16,
                    16,
                  ),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final article = searchResults[index];

                    return _buildArticleCard(
                      context,
                      article,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    Article article,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      article.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 15,
                          color: Colors.orange.shade800,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            article.category,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchText.isEmpty
                  ? Icons.menu_book_outlined
                  : Icons.search_off_rounded,
              size: 65,
              color: Colors.orange.shade300,
            ),

            const SizedBox(height: 16),

            Text(
              searchText.isEmpty
                  ? 'No articles available'
                  : 'No articles found',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              searchText.isEmpty
                  ? 'There are no articles available yet.'
                  : 'Try a different construction term.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 55,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load articles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}