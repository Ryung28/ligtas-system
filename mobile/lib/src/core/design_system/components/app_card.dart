import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../app_spacing.dart';
import '../app_theme.dart';

/// Professional card component with consistent styling and animations
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool animate;
  final Duration animationDelay;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.animate = true,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      elevation: elevation ?? AppElevation.card,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? AppRadius.cardRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? AppRadius.cardRadius,
        child: Container(
          padding: padding ?? AppSpacing.cardPaddingAll,
          child: child,
        ),
      ),
    );

    if (margin != null) {
      card = Container(
        margin: margin,
        child: card,
      );
    }

    if (animate) {
      return card
          .animate(delay: animationDelay)
          .fadeIn(duration: const Duration(milliseconds: 300), curve: Curves.easeOut)
          .slideY(begin: 0.1, end: 0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }

    return card;
  }
}

/// Professional status chip component
class AppStatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const AppStatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory AppStatusChip.success(String label, {IconData? icon}) {
    return AppStatusChip(
      label: label,
      backgroundColor: AppTheme.successGreen.withOpacity(0.1),
      textColor: AppTheme.successGreen,
      icon: icon,
    );
  }

  factory AppStatusChip.warning(String label, {IconData? icon}) {
    return AppStatusChip(
      label: label,
      backgroundColor: AppTheme.warningAmber.withOpacity(0.1),
      textColor: AppTheme.warningAmber,
      icon: icon,
    );
  }

  factory AppStatusChip.error(String label, {IconData? icon}) {
    return AppStatusChip(
      label: label,
      backgroundColor: AppTheme.errorRed.withOpacity(0.1),
      textColor: AppTheme.errorRed,
      icon: icon,
    );
  }

  factory AppStatusChip.info(String label, {IconData? icon}) {
    return AppStatusChip(
      label: label,
      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
      textColor: AppTheme.primaryBlue,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.allMd,
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppSizing.iconXs,
              color: textColor,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Professional loading shimmer component
class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.neutralGray200,
      highlightColor: Colors.white.withOpacity(0.6),
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.neutralGray200,
          borderRadius: borderRadius ?? AppRadius.allSm,
        ),
      ),
    );
  }
}

/// Professional empty state component
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizing.iconXl + 16,
              color: AppTheme.neutralGray400,
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 600))
                .scale(begin: const Offset(0.8, 0.8), duration: const Duration(milliseconds: 600)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.neutralGray600,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: const Duration(milliseconds: 200))
                .fadeIn(duration: const Duration(milliseconds: 400))
                .slideY(begin: 0.2, duration: const Duration(milliseconds: 400)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutralGray500,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: const Duration(milliseconds: 400))
                .fadeIn(duration: const Duration(milliseconds: 400))
                .slideY(begin: 0.2, duration: const Duration(milliseconds: 400)),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!
                  .animate(delay: const Duration(milliseconds: 600))
                  .fadeIn(duration: const Duration(milliseconds: 400))
                  .slideY(begin: 0.2, duration: const Duration(milliseconds: 400)),
            ],
          ],
        ),
      ),
    );
  }
}