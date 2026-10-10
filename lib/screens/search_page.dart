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

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();

  String searchText = '';
  String selectedCategoryFilter = 'All';

  final List<String> filterCategories = const [
    'All',
    'Materials',
    'Structural',
    'Finishing',
    'Site Safety',
    'Tools & Machinery',
  ];

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
    List<Article> filtered = articles;

    // Filter by Category Chip
    if (selectedCategoryFilter != 'All') {
      filtered = filtered
          .where((a) =>
              a.category.toLowerCase() == selectedCategoryFilter.toLowerCase())
          .toList();
    }

    // Filter by Search Query
    if (searchText.isEmpty) {
      return filtered;
    }

    final results = filtered.where((article) {
      final title = article.title.toLowerCase();
      final description = article.description.toLowerCase();
      final content = article.content.toLowerCase();
      final category = article.category.toLowerCase();

      return title.contains(searchText) ||
          description.contains(searchText) ||
          content.contains(searchText) ||
          category.contains(searchText);
    }).toList();

    // Exact and prefix title matches first
    results.sort((a, b) {
      final aTitle = a.title.toLowerCase();
      final bTitle = b.title.toLowerCase();

      final aExact = aTitle == searchText;
      final bExact = bTitle == searchText;

      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;

      final aStarts = aTitle.startsWith(searchText);
      final bStarts = bTitle.startsWith(searchText);

      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;

      return aTitle.compareTo(bTitle);
    });

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Search Encyclopedia',
        subtitle: 'Search across all construction articles & topics',
      ),
      body: Column(
        children: [
          // SEARCH INPUT & FILTERS AREA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: searchController,
                  onChanged: performSearch,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Search materials, standards, terms...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
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
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: 12),

                // CATEGORY FILTER CHIPS
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filterCategories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = filterCategories[index];
                      final isSelected = selectedCategoryFilter == cat;

                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategoryFilter = cat;
                          });
                        },
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        backgroundColor: AppColors.surfaceMuted,
                        selectedColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 1,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // RESULTS LIST
          Expanded(
            child: StreamBuilder<List<Article>>(
              stream: firestoreService.getArticles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(18),
                    itemCount: 4,
                    itemBuilder: (context, index) =>
                        const ArticleCardSkeleton(),
                  );
                }

                if (snapshot.hasError) {
                  return ErrorStateWidget(
                    message:
                        'Unable to search articles: ${snapshot.error}',
                    onRetry: () => setState(() {}),
                  );
                }

                final articles = snapshot.data ?? [];
                final searchResults = filterArticles(articles);

                if (searchResults.isEmpty) {
                  return EmptyStateWidget(
                    icon: searchText.isEmpty
                        ? Icons.menu_book_outlined
                        : Icons.search_off_rounded,
                    title: searchText.isEmpty
                        ? 'No Articles In This Category'
                        : 'No Results Found',
                    message: searchText.isEmpty
                        ? 'There are currently no articles in "$selectedCategoryFilter".'
                        : 'No matches found for "$searchText". Try another construction term or reset filters.',
                    buttonLabel: searchController.text.isNotEmpty ||
                            selectedCategoryFilter != 'All'
                        ? 'Reset Search'
                        : null,
                    onButtonPressed: () {
                      searchController.clear();
                      setState(() {
                        searchText = '';
                        selectedCategoryFilter = 'All';
                      });
                    },
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 2),
                      child: Text(
                        'Found ${searchResults.length} ${searchResults.length == 1 ? 'article' : 'articles'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    ...searchResults.map(
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
          ),
        ],
      ),
    );
  }
}