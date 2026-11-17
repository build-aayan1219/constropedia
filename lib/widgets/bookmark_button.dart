import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Interactive Bookmark toggle button for headers and cards.
class BookmarkButton extends StatelessWidget {
  final bool isBookmarked;
  final bool isLoading;
  final VoidCallback? onTap;
  final double size;

  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    this.isLoading = false,
    required this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: size + 16,
        height: size + 16,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    }

    return IconButton(
      iconSize: size,
      tooltip: isBookmarked ? 'Remove Bookmark' : 'Save Article',
      onPressed: onTap,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isBookmarked ? AppColors.primarySubtle : AppColors.surfaceMuted,
          shape: BoxShape.circle,
          border: Border.all(
            color: isBookmarked ? AppColors.primaryBorder : AppColors.border,
            width: 1,
          ),
        ),
        child: Icon(
          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
          size: size,
        ),
      ),
    );
  }
}
