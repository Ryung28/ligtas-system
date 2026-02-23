import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../app_theme.dart';

class LigtasErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const LigtasErrorState({
    super.key,
    this.title = 'System Alert',
    this.message = 'An unexpected error occurred while processing data.',
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Animated Icon Container ──
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.errorRed.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.errorRed,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .shake(hz: 3, duration: 2.seconds)
                .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), curve: Curves.easeInOut),

            const Gap(24),

            // ── Text Content ──
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppTheme.errorRed,
                letterSpacing: 2.0,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            const Gap(8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutralGray900.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

            if (onRetry != null) ...[
              const Gap(32),
              
              // ── Professional Retry Button ──
              SizedBox(
                width: 160,
                height: 48,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.neutralGray900,
                    elevation: 4,
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppTheme.neutralGray200),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 18),
                      Gap(8),
                      Text(
                        'RETRY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
            ],
          ],
        ),
      ),
    );
  }
}
