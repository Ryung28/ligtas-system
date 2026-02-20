import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/design_system/app_theme.dart';

class LoanListSkeleton extends StatelessWidget {
  const LoanListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      itemCount: 4,
      separatorBuilder: (_, __) => const Gap(16),
      itemBuilder: (context, index) {
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.8)),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon Skeleton
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
              ).animate(onPlay: (c) => c.repeat())
               .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.8)),
              
              const Gap(16),
              
              // Text Content Skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                     .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.8)),
                    const Gap(8),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                     .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.8)),
                  ],
                ),
              ),
              
              // Status Pill Skeleton
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
              ).animate(onPlay: (c) => c.repeat())
               .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.8)),
            ],
          ),
        );
      },
    );
  }
}
