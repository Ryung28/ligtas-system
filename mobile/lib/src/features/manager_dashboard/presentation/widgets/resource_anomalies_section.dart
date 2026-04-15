import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../../../core/design_system/app_theme.dart';
import '../../domain/entities/resource_anomaly.dart';
import 'anomaly_card.dart';

class ResourceAnomaliesSection extends StatelessWidget {
  final List<ResourceAnomaly> anomalies;
  final VoidCallback onViewAll;
  final Function(ResourceAnomaly)? onAnomalyTap;

  const ResourceAnomaliesSection({
    super.key,
    required this.anomalies,
    required this.onViewAll,
    this.onAnomalyTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = anomalies.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOGISTICS PULSE',
                style: GoogleFonts.lexend(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              if (!isEmpty)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'VIEW ALL',
                    style: GoogleFonts.lexend(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Gap(8),
        SizedBox(
          height: 180,
          child: isEmpty 
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _SentinelSecurePlaceholder(),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: anomalies.length,
                separatorBuilder: (context, index) => const Gap(16),
                itemBuilder: (context, index) {
                  final anomaly = anomalies[index];
                  return AnomalyCard(
                    anomaly: anomaly,
                    onTap: onAnomalyTap != null ? () => onAnomalyTap!(anomaly) : null,
                  );
                },
              ),
        ),
      ],
    );
  }
}

class _SentinelSecurePlaceholder extends StatelessWidget {
  const _SentinelSecurePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: AppTheme.successGreen.withValues(alpha: 0.4),
            size: 40,
          ),
          const Gap(12),
          Text(
            'SENTINEL SECURE',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 2,
            ),
          ),
          Text(
            'No critical anomalies in the current quadrant.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
