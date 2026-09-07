import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/firestore_service.dart';

class ArticlePage extends StatefulWidget {
  final Article article;

  const ArticlePage({
    super.key,
    required this.article,
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

  // --------------------------------------------------
  // CHECK BOOKMARK
  // --------------------------------------------------

  Future<void> checkBookmark() async {
    try {
      final bookmarked = await _firestoreService.isBookmarked(
        title: widget.article.title,
      );

      if (!mounted) return;

      setState(() {
        isBookmarked = bookmarked;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('Error checking bookmark: $e');
    }
  }

  // --------------------------------------------------
  // TOGGLE BOOKMARK
  // --------------------------------------------------

  Future<void> toggleBookmark() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (isBookmarked) {
        await _firestoreService.removeBookmark(
          title: widget.article.title,
        );

        if (!mounted) return;

        setState(() {
          isBookmarked = false;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from bookmarks'),
          ),
        );
      } else {
        await _firestoreService.addBookmark(
          title: widget.article.title,
          description: widget.article.description,
          content: widget.article.content,
          category: widget.article.category,
          imageUrl: widget.article.imageUrl,
        );

        if (!mounted) return;

        setState(() {
          isBookmarked = true;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to bookmarks'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );

      debugPrint('Bookmark error: $e');
    }
  }

  // --------------------------------------------------
  // KEY POINT CARD
  // --------------------------------------------------

  Widget _buildPoint(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 16,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ARTICLE IMAGE
  // --------------------------------------------------

  Widget _buildArticleImage() {
    final imageUrl = widget.article.imageUrl;

    // No image URL
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 55,
              color: Colors.orange.shade300,
            ),
            const SizedBox(height: 10),
            Text(
              'No image available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Image URL exists
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            width: double.infinity,
            height: 220,
            color: Colors.orange.shade50,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          return Container(
            width: double.infinity,
            height: 220,
            color: Colors.orange.shade50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 55,
                  color: Colors.orange.shade300,
                ),
                const SizedBox(height: 10),
                Text(
                  'Unable to load image',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

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
            tooltip: isBookmarked
                ? 'Remove Bookmark'
                : 'Add Bookmark',
            onPressed: isLoading ? null : toggleBookmark,
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
            ),
          ),
        ],
      ),

      // --------------------------------------------------
      // ARTICLE BODY
      // --------------------------------------------------

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IMAGE
            _buildArticleImage(),

            const SizedBox(height: 18),

            // ARTICLE HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(18),
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
                      Icons.menu_book_rounded,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    article.category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // DEFINITION
            // --------------------------------------------------

            const Text(
              'Definition',
              style: TextStyle(
                fontSize: 20,
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
                padding: const EdgeInsets.all(16),
                child: Text(
                  article.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // CONTENT
            // --------------------------------------------------

            const Text(
              'Content',
              style: TextStyle(
                fontSize: 20,
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
                padding: const EdgeInsets.all(16),
                child: Text(
                  article.content.isNotEmpty
                      ? article.content
                      : 'No content available for this article.',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // KEY POINTS
            // --------------------------------------------------

            const Text(
              'Key Points',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _buildPoint(
              'Important construction material used in various applications.',
            ),

            _buildPoint(
              'Its properties and usage depend on the specific construction requirement.',
            ),

            _buildPoint(
              'Proper selection and application can improve construction quality and durability.',
            ),

            const SizedBox(height: 14),

            // --------------------------------------------------
            // BOOKMARK BUTTON
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : toggleBookmark,
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                label: Text(
                  isBookmarked
                      ? 'Remove Bookmark'
                      : 'Bookmark Article',
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}