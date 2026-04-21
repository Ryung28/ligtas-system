import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/resource_anomaly.dart';

/// Analyst note + stock progress.
class AnomalyStrategicOverview extends StatelessWidget {
  final ResourceAnomaly anomaly;

  const AnomalyStrategicOverview({super.key, required this.anomaly});

  @override
  Widget build(BuildContext context) {
    final a = anomaly;
    final current = a.currentStock;
    final goal = a.maxStock ?? a.thresholdStock;
    final readiness = goal > 0 ? (current / goal * 100).clamp(0, 100).toInt() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: const Color(0xFFB91C1C), size: 16),
                  const Gap(8),
                  Text('ANALYST LOG',
                      style: GoogleFonts.lexend(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFB91C1C))),
                ],
              ),
              const Gap(8),
              Text(a.reason,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7F1D1D))),
            ],
          ),
        ),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Stock progress',
                style: GoogleFonts.lexend(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF64748B))),
            Text('$readiness% of max target',
                style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF001A33))),
          ],
        ),
        const Gap(8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Current: $current',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Max target: $goal',
                textAlign: TextAlign.end,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
        const Gap(8),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            widthFactor: readiness / 100,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
