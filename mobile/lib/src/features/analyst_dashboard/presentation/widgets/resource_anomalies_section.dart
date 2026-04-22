import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/resource_anomaly.dart';
import 'anomaly_card.dart' show AnomalyCard, kAnomalyStripCardHeight;
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/app_theme.dart';

import 'package:go_router/go_router.dart';

/// Tactical Section: Aggregates Stock & Operational Anomalies
class ResourceAnomaliesSection extends StatelessWidget {
  final List<ResourceAnomaly> anomalies;
  final VoidCallback? onViewAll;
  final VoidCallback? onTuningTap; // ⚙️ ALERT CONFIG
  final Function(ResourceAnomaly)? onAnomalyTap;

  const ResourceAnomaliesSection({
    super.key,
    required this.anomalies,
    this.onViewAll,
    this.onTuningTap,
    this.onAnomalyTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverloaded = anomalies.length >= 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alerts',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.neutralGray900,
                  letterSpacing: -1.0,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/manager/queue');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.neutralGray900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'SEE ALL (${anomalies.length})',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        
        // ── Horizontal Scrollable Alert Stream ──
        if (anomalies.isEmpty)
          _buildEmptyState()
        else
          SizedBox(
            height: kAnomalyStripCardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: anomalies.length > 5 ? 5 : anomalies.length,
              separatorBuilder: (_, __) => const Gap(12),
              itemBuilder: (context, index) {
                final anomaly = anomalies[index];
                return AnomalyCard(
                  key: ValueKey('anomaly_${anomaly.id}'), // 🔑 ANCHOR: Matches Element to State
                  anomaly: anomaly,
                  onTap: onAnomalyTap != null ? () => onAnomalyTap!(anomaly) : null,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: AppTheme.successGreen.withOpacity(0.5), size: 32),
            const Gap(12),
            Text(
              'EQUIPMENT READY: NO PENDING ALERTS',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.neutralGray500,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
