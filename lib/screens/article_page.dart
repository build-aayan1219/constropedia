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
        title: const Text(
          'Article',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : toggleBookmark,
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_outline,
            ),
            tooltip: isBookmarked
                ? 'Remove Bookmark'
                : 'Bookmark',
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ARTICLE HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.orange.shade100,
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: const Icon(
                      Icons.menu_book,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // DEFINITION
            const Text(
              'Definition',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 1,
              margin: EdgeInsets.zero,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // KEY POINTS
            const Text(
              'Key Points',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _buildPoint(
              'Commonly used in construction projects.',
            ),

            _buildPoint(
              'Available in different types and grades.',
            ),

            _buildPoint(
              'Proper handling and storage is important.',
            ),

            const SizedBox(height: 28),

            // USES
            const Text(
              'Uses',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 1,
              margin: EdgeInsets.zero,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Text(
                  'This material is widely used in construction for building and structural applications.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BOOKMARK BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,

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
                      : 'Bookmark Article',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REUSABLE KEY POINT WIDGET
  Widget _buildPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),

                padding: const EdgeInsets.all(5),

                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.check,
                  size: 15,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}