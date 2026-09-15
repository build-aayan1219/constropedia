import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/mixture_record.dart';
import '../services/firestore_service.dart';
import 'cement_mixture_data_page.dart';
import 'component_detail_page.dart';

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

  ConcreteMixtureRecord? _sampleMixtureRecord;
  bool _isLoadingMixture = false;
  String? _mixtureError;

  bool get _isCementArticle {
    final title = widget.article.title.trim().toLowerCase();
    final id = widget.article.id.trim().toLowerCase();
    return title.contains('cement') || id == 'cement';
  }

  @override
  void initState() {
    super.initState();
    checkBookmark();
    if (_isCementArticle) {
      _loadSampleMixture();
    }
  }

  Future<void> _loadSampleMixture() async {
    setState(() {
      _isLoadingMixture = true;
      _mixtureError = null;
    });

    try {
      final sample = await _firestoreService.getSampleMixtureRecord(
        articleId: 'cement',
      );

      if (!mounted) return;
      setState(() {
        _sampleMixtureRecord = sample;
        _isLoadingMixture = false;
      });
    } catch (e) {
      debugPrint('Error loading mixture sample: $e');
      if (!mounted) return;
      setState(() {
        _mixtureError = 'Unable to load mixture data. Please try again.';
        _isLoadingMixture = false;
      });
    }
  }

  // --------------------------------------------------
  // CHECK BOOKMARK
  // --------------------------------------------------

  Future<void> checkBookmark() async {
    try {
      final bookmarked = await _firestoreService.isBookmarked(
        articleId: widget.article.id,
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
          articleId: widget.article.id,
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
          articleId: widget.article.id,
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
            // CONCRETE MIXTURE DATA SECTION (FOR CEMENT)
            // --------------------------------------------------
            if (_isCementArticle) ...[
              _buildConcreteMixtureSection(),
              const SizedBox(height: 24),
            ],

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

  // --------------------------------------------------
  // CONCRETE MIXTURE SECTION
  // --------------------------------------------------

  Widget _buildConcreteMixtureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Concrete Mixture Components',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Standard component proportions and performance metrics from laboratory concrete mixes.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 14),

        if (_isLoadingMixture)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Loading mixture components...'),
                  ],
                ),
              ),
            ),
          )
        else if (_mixtureError != null)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    _mixtureError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadSampleMixture,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (_sampleMixtureRecord == null)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Center(
                child: Text('No mixture data available.'),
              ),
            ),
          )
        else ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sampleMixtureRecord!.components.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, idx) {
              final comp = _sampleMixtureRecord!.components[idx];
              return _buildComponentCard(comp);
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CementMixtureDataPage(),
                  ),
                );
              },
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text(
                'View Mixture Data',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade900,
                side: BorderSide(
                  color: Colors.orange.shade700,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildComponentCard(MixtureComponentItem comp) {
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComponentDetailPage(component: comp),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comp.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    comp.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    comp.unit,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}