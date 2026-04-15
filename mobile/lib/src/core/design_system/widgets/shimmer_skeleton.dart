import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';

class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0), // Slate 200
      highlightColor: const Color(0xFFF8FAFC), // Slate 50
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double height;
  
  const ShimmerCard({super.key, this.height = 84});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const ShimmerSkeleton(width: 52, height: 52, borderRadius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const ShimmerSkeleton(width: 140, height: 16),
                const SizedBox(height: 8),
                const ShimmerSkeleton(width: 80, height: 12),
              ],
            ),
          ),
          const ShimmerSkeleton(width: 70, height: 32, borderRadius: 20),
        ],
      ),
    );
  }
}
