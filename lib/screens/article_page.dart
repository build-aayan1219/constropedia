import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/mixture_record.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/bookmark_button.dart';
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
  bool isLoadingBookmark = true;

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
        articleId: widget.article.id.isNotEmpty ? widget.article.id : 'cement',
      );

      if (!mounted) return;
      setState(() {
        _sampleMixtureRecord = sample;
        _isLoadingMixture = false;
        if (sample == null) {
          _mixtureError = 'Unable to load mixture data. Tap reload to retry.';
        }
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
        isLoadingBookmark = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingBookmark = false;
      });

      debugPrint('Error checking bookmark: $e');
    }
  }

  // --------------------------------------------------
  // TOGGLE BOOKMARK
  // --------------------------------------------------

  Future<void> toggleBookmark() async {
    if (isLoadingBookmark) return;

    setState(() {
      isLoadingBookmark = true;
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
          isLoadingBookmark = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.bookmark_remove_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Removed from bookmarks'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          isLoadingBookmark = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Article saved to bookmarks!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingBookmark = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      debugPrint('Bookmark error: $e');
    }
  }

  // --------------------------------------------------
  // KEY POINT TILE
  // --------------------------------------------------

  Widget _buildPoint(String title, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryBorder.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
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
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 230,
        decoration: BoxDecoration(
          color: AppColors.primarySubtle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: hasImage
            ? Image.network(
                imageUrl,
                width: double.infinity,
                height: 230,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.construction_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Construction Encyclopedia Image',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: article.title,
        subtitle: article.category,
        actions: [
          BookmarkButton(
            isBookmarked: isBookmarked,
            isLoading: isLoadingBookmark,
            onTap: toggleBookmark,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ARTICLE IMAGE HERO
            _buildArticleImage(),

            const SizedBox(height: 18),

            // CATEGORY BADGE & TITLE HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryBorder.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Text(
                          article.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '3 min read',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // OVERVIEW & DEFINITION SECTION
            _buildSectionHeader('Overview & Definition', Icons.info_outline_rounded),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                article.description.isNotEmpty
                    ? article.description
                    : 'A fundamental civil engineering material widely utilized across modern infrastructure and structural projects.',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // DETAILED CONTENT SECTION
            _buildSectionHeader('Technical Specifications & Content', Icons.description_outlined),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                article.content.isNotEmpty
                    ? article.content
                    : 'Standard construction specifications mandate thorough quality control, appropriate mix ratios, and adherence to regional building codes to achieve structural integrity and long-term durability.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.65,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // KEY POINTS
            _buildSectionHeader('Key Engineering Points', Icons.lightbulb_outline_rounded),
            const SizedBox(height: 10),
            _buildPoint(
              'Structural Reliability',
              'Selection and installation methods directly impact load-carrying capacity and lifecycle longevity.',
            ),
            _buildPoint(
              'Code Compliance',
              'Must adhere to standard building codes, testing protocols, and safety standards.',
            ),
            _buildPoint(
              'Environmental Durability',
              'Formulated to withstand thermal variations, moisture penetration, and environmental degradation.',
            ),

            const SizedBox(height: 22),

            // CONCRETE MIXTURE DATA SECTION (FOR CEMENT)
            if (_isCementArticle) ...[
              _buildConcreteMixtureSection(),
              const SizedBox(height: 22),
            ],

            // BOOKMARK ACTION BUTTON
            PrimaryButton(
              label: isBookmarked ? 'Remove from Bookmarks' : 'Bookmark This Article',
              icon: isBookmarked ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded,
              isOutlined: isBookmarked,
              isLoading: isLoadingBookmark,
              onPressed: toggleBookmark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // CONCRETE MIXTURE SECTION
  // --------------------------------------------------

  Widget _buildConcreteMixtureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Concrete Mixture Components', Icons.science_outlined),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Lab Dataset',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Standard component proportions and performance metrics from laboratory concrete mixes.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),

        if (_isLoadingMixture)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Loading mixture components...',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else if (_mixtureError != null)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text(
                  _mixtureError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Retry Loading',
                  width: 150,
                  height: 42,
                  onPressed: _loadSampleMixture,
                ),
              ],
            ),
          )
        else if (_sampleMixtureRecord == null)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  const Text('No mixture data available.'),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: 'Reload',
                    width: 140,
                    height: 40,
                    onPressed: _loadSampleMixture,
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
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, idx) {
              final comp = _sampleMixtureRecord!.components[idx];
              return _buildComponentCard(comp);
            },
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'View Complete Mixture Dataset',
            icon: Icons.table_chart_outlined,
            isOutlined: true,
            height: 48,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CementMixtureDataPage(),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildComponentCard(MixtureComponentItem comp) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        comp.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      comp.value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comp.unit,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}