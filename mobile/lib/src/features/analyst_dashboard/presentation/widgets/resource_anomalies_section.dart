import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/resource_anomaly.dart';
import 'anomaly_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/app_theme.dart';

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
    final criticalCount = anomalies.where((e) => e.severity == AnomalySeverity.critical).length;
    final isOverloaded = anomalies.length >= 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Section: Operational Awareness ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EQUIPMENT STATUS',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.neutralGray500,
                  letterSpacing: 2.0,
                ),
              ),
              if (anomalies.isNotEmpty)
                GestureDetector(
                  onTap: onViewAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isOverloaded ? AppTheme.errorRed.withOpacity(0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isOverloaded ? Border.all(color: AppTheme.errorRed.withOpacity(0.2)) : null,
                    ),
                    child: Row(
                      children: [
                        if (isOverloaded) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.errorRed,
                              shape: BoxShape.circle,
                            ),
                          ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1,1), end: const Offset(1.5,1.5)).then().scale(begin: const Offset(1.5,1.5), end: const Offset(1,1)),
                          const Gap(8),
                        ],
                        Text(
                          isOverloaded ? 'MANAGE QUEUE (${anomalies.length})' : 'VIEW ALL',
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isOverloaded ? AppTheme.errorRed : AppTheme.primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Gap(10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Stock Alerts',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.neutralGray900,
                    letterSpacing: -1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(8), 
              
              // ⚙️ TUNING TRIGGER
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTuningTap?.call();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.neutralGray50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.neutralGray100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune_rounded, size: 14, color: AppTheme.neutralGray900),
                      const Gap(6),
                      Text(
                        'TUNING',
                        style: GoogleFonts.lexend(
                          fontSize: 9, 
                          fontWeight: FontWeight.w800, 
                          color: AppTheme.neutralGray900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
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
            height: 128,
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
