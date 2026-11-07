import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Clean, bulletproof Google "G" logo badge built with pure widgets
/// without fragile canvas interop on Flutter Web.
class _GoogleLogoBadge extends StatelessWidget {
  final double size;
  const _GoogleLogoBadge({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontWeight: FontWeight.w900,
          fontSize: 13,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Continue with Google',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        onPressed: (isLoading == true) ? null : onPressed,
        child: (isLoading == true)
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.orange,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GoogleLogoBadge(size: 22),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
