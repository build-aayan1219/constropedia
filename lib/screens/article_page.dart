import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/mixture_record.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
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
        if (sample == null) {
          _mixtureError = 'Unable to load mixture data. Please tap retry.';
        }
      });
    } catch (e) {
      debugPrint('Error loading mixture sample: $e');
      if (!mounted) return;
      setState(() {
        _mixtureError = 'Unable to load mixture data. Please try again.\n$e';
        _isLoadingMixture = false;
      });
    }
  }

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
        SnackBar(
          content: Text(
            'Something went wrong. Please try again.\n$e',
          ),
        ),
      );

      debugPrint('Bookmark error: $e');
    }
  }

  Widget _buildPoint(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: AppColors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
    final imageUrl = widget.article.imageUrl;

    Widget placeholder({
      required IconData icon,
      required String label,
    }) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.orangeSoft,
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: AppColors.orangeDark),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      );
    }

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return placeholder(
        icon: Icons.apartment_outlined,
        label: 'No image available',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radius),
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
            color: AppColors.orangeSoft,
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
          return placeholder(
            icon: Icons.broken_image_outlined,
            label: 'Unable to load image',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          IconButton(
            tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
            onPressed: isLoading ? null : toggleBookmark,
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isBookmarked ? AppColors.orange : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildArticleImage(),
            const SizedBox(height: 18),
            CategoryChip(label: article.category),
            const SizedBox(height: 10),
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            const AppSectionHeader(title: 'Definition'),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  article.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'Content'),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  article.content.isNotEmpty
                      ? article.content
                      : 'No content available for this article.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.7,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'Key points'),
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
            const SizedBox(height: 10),
            if (_isCementArticle) ...[
              _buildConcreteMixtureSection(),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : toggleBookmark,
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                label: Text(
                  isBookmarked ? 'Remove bookmark' : 'Bookmark article',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConcreteMixtureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Concrete mixture components',
          subtitle:
              'Standard component proportions and performance metrics from laboratory concrete mixes.',
        ),
        const SizedBox(height: 14),
        if (_isLoadingMixture)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Loading mixture components...'),
                ],
              ),
            ),
          )
        else if (_mixtureError != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    _mixtureError!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
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
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Text('No mixture data available.'),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _loadSampleMixture,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reload'),
                  ),
                ],
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
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, idx) {
              final comp = _sampleMixtureRecord!.components[idx];
              return _buildComponentCard(comp);
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
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
              label: const Text('View mixture data'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildComponentCard(MixtureComponentItem comp) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComponentDetailPage(component: comp),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comp.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      comp.value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orangeDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    comp.unit,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
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
