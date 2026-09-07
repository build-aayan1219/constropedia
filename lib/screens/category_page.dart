import 'package:flutter/material.dart';
import 'article_page.dart';

class CategoryPage extends StatelessWidget {
  final String categoryName;

  const CategoryPage({
    super.key,
    required this.categoryName,
  });

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

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // PAGE HEADING
          Text(
            '$categoryName Articles',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Explore construction terms and concepts.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 20),

          // CEMENT
          _buildArticleCard(
            context: context,
            title: 'Cement',
            description:
                'Learn about cement and its uses in construction.',
            icon: Icons.inventory_2_outlined,
            articleDescription:
                'Cement is a binding material commonly used in construction. '
                'It is mixed with water and other materials to produce '
                'concrete and mortar.',
          ),

          // CONCRETE
          _buildArticleCard(
            context: context,
            title: 'Concrete',
            description:
                'Learn about concrete and its applications.',
            icon: Icons.foundation_outlined,
            articleDescription:
                'Concrete is a construction material made by combining '
                'cement, water and aggregates. It is widely used for '
                'buildings, roads and other structures.',
          ),

          // BRICKS
          _buildArticleCard(
            context: context,
            title: 'Bricks',
            description:
                'Learn about bricks and their use in construction.',
            icon: Icons.domain_outlined,
            articleDescription:
                'Bricks are commonly used building units made from '
                'materials such as clay. They are used for walls, '
                'partitions and other construction applications.',
          ),
        ],
      ),
    );
  }

  // ARTICLE CARD
  Widget _buildArticleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required String articleDescription,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),

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
                title: title,
                description: articleDescription,
              ),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              // ARTICLE ICON
              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // ARTICLE INFORMATION
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ARROW
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}