import 'package:flutter/material.dart';
import '../models/article.dart';
import 'article_page.dart';

class CategoryPage extends StatelessWidget {
  final String categoryName;

  const CategoryPage({
    super.key,
    required this.categoryName,
  });

  // Temporary local data.
  // Later this will come from Firestore.
  List<Article> get articles {
    return [
      Article(
        id: 'cement',
        title: 'Cement',
        description:
            'A binding material used in construction to hold other materials together.',
        content:
            'Cement is one of the most important materials used in construction. '
            'It is commonly mixed with water, sand, and aggregates to produce concrete and mortar.',
        category: 'Materials',
      ),
      Article(
        id: 'concrete',
        title: 'Concrete',
        description:
            'A composite construction material made using cement, aggregates, and water.',
        content:
            'Concrete is widely used for foundations, columns, beams, slabs, and other structural elements. '
            'Its strength and durability make it one of the most commonly used construction materials.',
        category: 'Materials',
      ),
      Article(
        id: 'bricks',
        title: 'Bricks',
        description:
            'Small masonry units commonly used for walls and other construction work.',
        content:
            'Bricks are commonly used to construct walls, partitions, and other masonry structures. '
            'They are available in different sizes, types, and strengths depending on their application.',
        category: 'Materials',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$categoryName Articles',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Explore construction terms and concepts.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: articles.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final article = articles[index];

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
}