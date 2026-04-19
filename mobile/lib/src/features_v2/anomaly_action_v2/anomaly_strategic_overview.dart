import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/resource_anomaly.dart';

/// Stock ledger + analyst log + deployment gap (parity with `anomaly_action_hero`).
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STOCK LEDGER',
                  style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5)),
              const Gap(4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(current.toString().padLeft(2, '0'),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF001A33),
                          height: 1.0)),
                  Text(' / $goal',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF64748B).withOpacity(0.4),
                          height: 1.5)),
                ],
              ),
              Text('Available Units',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B))),
            ],
          ),
        ),
        const Gap(12),
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
            Text('DEPLOYMENT GAP',
                style: GoogleFonts.lexend(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF64748B))),
            Text('$readiness% Readiness',
                style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF001A33))),
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
