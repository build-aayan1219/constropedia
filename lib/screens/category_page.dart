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
        title: Text(categoryName),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          const Text(
            'Articles',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          // CEMENT
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.article,
              ),

              title: const Text(
                'Cement',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text(
                'Learn about cement and its uses in construction.',
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArticlePage(
                      title: 'Cement',
                      description:
                          'Cement is a binding material commonly used '
                          'in construction. It is mixed with water and '
                          'other materials to produce concrete and mortar.',
                    ),
                  ),
                );
              },
            ),
          ),

          // CONCRETE
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.article,
              ),

              title: const Text(
                'Concrete',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text(
                'Learn about concrete and its applications.',
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArticlePage(
                      title: 'Concrete',
                      description:
                          'Concrete is a construction material made '
                          'by combining cement, water and aggregates. '
                          'It is widely used for buildings, roads and '
                          'other structures.',
                    ),
                  ),
                );
              },
            ),
          ),

          // BRICKS
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.article,
              ),

              title: const Text(
                'Bricks',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text(
                'Learn about bricks and their use in construction.',
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArticlePage(
                      title: 'Bricks',
                      description:
                          'Bricks are commonly used building units '
                          'made from materials such as clay. They are '
                          'used for walls, partitions and other '
                          'construction applications.',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}