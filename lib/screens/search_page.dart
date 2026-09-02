import 'package:flutter/material.dart';
import 'article_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();

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

  void searchArticles(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults = articles;
      } else {
        searchResults = articles.where((article) {
          final title = article['title']!.toLowerCase();
          final description = article['description']!.toLowerCase();
          final searchText = query.toLowerCase();

          return title.contains(searchText) ||
              description.contains(searchText);
        }).toList();
      }
    });
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
        title: const Text('Search'),
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
                        onPressed: () {
                          searchController.clear();
                          searchArticles('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

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

            const SizedBox(height: 10),

            // RESULTS
            Expanded(
              child: searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'No articles found.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,

                      itemBuilder: (context, index) {
                        final article = searchResults[index];

                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.article,
                            ),

                            title: Text(
                              article['title']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Text(
                              article['description']!,
                            ),

                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                            ),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticlePage(
                                    title: article['title']!,
                                    description:
                                        article['description']!,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}