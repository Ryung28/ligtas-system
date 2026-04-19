import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

/// Same copy and layout as `AnomalyActionHero._handleRestock` confirmation.
Future<bool?> showInjectionConfirmDialog(
  BuildContext context, {
  required String itemName,
  required int? inventoryId,
  required String hubDisplayName,
  required String previewHubName,
  required bool previewMismatch,
  required int goodQty,
  required int damagedQty,
  required int maintQty,
  required int lostQty,
  required int total,
}) {
  final onyx = const Color(0xFF001A33);
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Confirm injection',
          style: GoogleFonts.lexend(
              fontSize: 18, fontWeight: FontWeight.w900, color: onyx)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stock will be added to this inventory record:',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onyx.withOpacity(0.65)),
            ),
            const Gap(10),
            Text(itemName,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15, fontWeight: FontWeight.w800, color: onyx)),
            const Gap(4),
            if (inventoryId != null)
              Text('Inventory #$inventoryId',
                  style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: onyx.withOpacity(0.45))),
            const Gap(14),
            Text('Hub (authoritative)',
                style: GoogleFonts.lexend(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: onyx.withOpacity(0.45),
                    letterSpacing: 0.6)),
            const Gap(4),
            Text(hubDisplayName,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15, fontWeight: FontWeight.w800, color: onyx)),
            if (previewMismatch) ...[
              const Gap(12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFF59E0B).withOpacity(0.35)),
                ),
                child: Text(
                  'Your preview hub is "$previewHubName". The write still applies only to "$hubDisplayName".',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: onyx.withOpacity(0.85),
                      height: 1.35),
                ),
              ),
            ],
            const Gap(14),
            Text('Quantities',
                style: GoogleFonts.lexend(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: onyx.withOpacity(0.45),
                    letterSpacing: 0.6)),
            const Gap(6),
            Text(
              'Good $goodQty · Damaged $damagedQty · Maintenance $maintQty · Lost $lostQty',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onyx.withOpacity(0.85)),
            ),
            const Gap(6),
            Text('Total $total units',
                style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: onyx)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Cancel',
              style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w800,
                  color: onyx.withOpacity(0.55))),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Confirm injection',
              style: GoogleFonts.lexend(fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );
}
