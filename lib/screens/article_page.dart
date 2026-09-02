import 'package:flutter/material.dart';

class ArticlePage extends StatelessWidget {
  final String title;
  final String description;

  const ArticlePage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // TITLE
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // DEFINITION
            const Text(
              'Definition',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            // KEY POINTS
            const Text(
              'Key Points',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              '• Commonly used in construction projects.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),

            const Text(
              '• Available in different types and grades.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),

            const Text(
              '• Proper handling and storage is important.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 25),

            // USES
            const Text(
              'Uses',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'This material is widely used in construction '
              'for building and structural applications.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // BOOKMARK BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bookmark feature coming soon'),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.bookmark_outline,
                ),

                label: const Text(
                  'Bookmark',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}