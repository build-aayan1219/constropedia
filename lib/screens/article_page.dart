import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ArticlePage extends StatefulWidget {
  final String title;
  final String description;

  const ArticlePage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final FirestoreService _firestoreService = FirestoreService();

  bool isBookmarked = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkBookmark();
  }

  // CHECK WHETHER ARTICLE IS ALREADY BOOKMARKED
  Future<void> checkBookmark() async {
    try {
      bool result = await _firestoreService.isBookmarked(
        title: widget.title,
      );

      if (mounted) {
        setState(() {
          isBookmarked = result;
          isLoading = false;
        });
      }
    } catch (e) {
      print('CHECK BOOKMARK ERROR: $e');

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ADD OR REMOVE BOOKMARK
  Future<void> toggleBookmark() async {
    try {
      if (isBookmarked) {
        await _firestoreService.removeBookmark(
          title: widget.title,
        );

        if (mounted) {
          setState(() {
            isBookmarked = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bookmark removed'),
            ),
          );
        }
      } else {
        await _firestoreService.addBookmark(
          title: widget.title,
          description: widget.description,
        );

        if (mounted) {
          setState(() {
            isBookmarked = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Article bookmarked'),
            ),
          );
        }
      }
    } catch (e) {
      print('BOOKMARK ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    }
  }

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
            // ARTICLE TITLE
            Text(
              widget.title,
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
              widget.description,
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
              'This material is widely used in construction for building and structural applications.',
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
                onPressed: isLoading ? null : toggleBookmark,

                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                ),

                label: Text(
                  isBookmarked
                      ? 'Remove Bookmark'
                      : 'Bookmark',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}