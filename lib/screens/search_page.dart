import 'package:flutter/material.dart';
import 'article_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();

  // Temporary article data.
  // This will later be replaced with Firestore data.
  final List<Map<String, String>> articles = [
    {
      'title': 'Cement',
      'description':
          'Cement is a binding material commonly used in construction.',
    },
    {
      'title': 'Concrete',
      'description':
          'Concrete is a construction material made using cement, water and aggregates.',
    },
    {
      'title': 'Bricks',
      'description':
          'Bricks are commonly used building units made from materials such as clay.',
    },
    {
      'title': 'Steel',
      'description':
          'Steel is a strong construction material commonly used for structural purposes.',
    },
    {
      'title': 'Foundation',
      'description':
          'A foundation transfers the load of a building safely to the ground.',
    },
  ];

  List<Map<String, String>> searchResults = [];

  @override
  void initState() {
    super.initState();
    searchResults = articles;
  }

  // Search articles by TITLE only.
  void searchArticles(String query) {
    setState(() {
      final searchText = query.trim().toLowerCase();

      if (searchText.isEmpty) {
        searchResults = articles;
      } else {
        searchResults = articles.where((article) {
          final title = article['title']!.toLowerCase();

          return title.contains(searchText);
        }).toList();
      }
    });
  }

  // Clear the search field.
  void clearSearch() {
    searchController.clear();
    searchArticles('');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
            // SEARCH BAR
            TextField(
              controller: searchController,
              onChanged: searchArticles,

              decoration: InputDecoration(
                hintText: 'Search construction terms...',
                prefixIcon: const Icon(Icons.search),

                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: clearSearch,
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear search',
                      )
                    : null,

                filled: true,
                fillColor: Colors.grey.shade100,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
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

            // RESULTS TITLE
            Text(
              searchController.text.isEmpty
                  ? 'All Articles'
                  : 'Search Results',

              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // SEARCH RESULTS
            Expanded(
              child: searchResults.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: searchResults.length,

                      itemBuilder: (context, index) {
                        final article = searchResults[index];

                        return _buildArticleCard(article);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Article result card.
  Widget _buildArticleCard(Map<String, String> article) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        leading: Container(
          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),

          child: const Icon(
            Icons.menu_book,
            size: 26,
          ),
        ),

        title: Text(
          article['title']!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            article['description']!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticlePage(
                title: article['title']!,
                description: article['description']!,
              ),
            ),
          );
        },
      ),
    );
  }

  // Empty search result UI.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

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