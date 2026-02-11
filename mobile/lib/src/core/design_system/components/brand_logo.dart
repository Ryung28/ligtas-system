import 'package:flutter/material.dart';
import '../../config/branding.dart';
import '../app_theme.dart';

/// Brand logo widget with fallback icon
class BrandLogo extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;

  const BrandLogo({
    super.key,
    this.width = 140,
    this.height = 60,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Branding.logoAssetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.neutralGray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shield_rounded,
            color: AppTheme.primaryBlue,
            size: 32,
          ),
        );
      },
    );
  }
}
