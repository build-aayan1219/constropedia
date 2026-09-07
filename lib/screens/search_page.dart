import 'package:flutter/material.dart';
import '../models/article.dart';
import 'article_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();

  final List<Article> articles = [
    Article(
      id: 'cement',
      title: 'Cement',
      description:
          'A binding material used in construction to hold other materials together.',
      content:
          'Cement is one of the most important materials used in construction.',
      category: 'Materials',
    ),
    Article(
      id: 'concrete',
      title: 'Concrete',
      description:
          'A composite construction material made using cement, aggregates, and water.',
      content:
          'Concrete is widely used for foundations, columns, beams, slabs, and other structural elements.',
      category: 'Materials',
    ),
    Article(
      id: 'bricks',
      title: 'Bricks',
      description:
          'Small masonry units commonly used for walls and other construction work.',
      content:
          'Bricks are commonly used to construct walls, partitions, and other masonry structures.',
      category: 'Materials',
    ),
    Article(
      id: 'steel',
      title: 'Steel',
      description:
          'A strong construction material commonly used for reinforcement and structural frameworks.',
      content:
          'Steel is widely used in construction because of its high strength and durability.',
      category: 'Structural',
    ),
    Article(
      id: 'foundation',
      title: 'Foundation',
      description:
          'The structural base of a building that transfers loads safely to the ground.',
      content:
          'A foundation provides stability to a structure by transferring its loads to the soil.',
      category: 'Structural',
    ),
  ];

  List<Article> searchResults = [];

  @override
  void initState() {
    super.initState();
    searchResults = articles;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void searchArticles(String query) {
    final searchText = query.trim().toLowerCase();

    setState(() {
      if (searchText.isEmpty) {
        searchResults = articles;
      } else {
        searchResults = articles.where((article) {
          final title = article.title.toLowerCase();

          // Search only by article title.
          return title.contains(searchText);
        }).toList();
      }
    });
  }

  void clearSearch() {
    searchController.clear();

    setState(() {
      searchResults = articles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              onChanged: searchArticles,
              decoration: InputDecoration(
                hintText: 'Search construction terms...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: clearSearch,
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

            const SizedBox(height: 24),

            Text(
              'Search Results',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: searchResults.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      itemCount: searchResults.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final article = searchResults[index];

                        return _buildArticleCard(
                          context,
                          article,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    Article article,
  ) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.4,
                      ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No articles found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try searching for another construction term.',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}