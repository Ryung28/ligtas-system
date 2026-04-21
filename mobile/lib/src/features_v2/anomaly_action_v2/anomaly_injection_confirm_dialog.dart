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
    barrierColor: Colors.black.withOpacity(0.34),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: onyx.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: onyx.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          size: 18,
                          color: onyx,
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          'Confirm add stock',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: onyx,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(6),
                  Text(
                    'Please review details before saving.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: onyx.withOpacity(0.56),
                    ),
                  ),
                  const Gap(16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: onyx.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: onyx,
                          ),
                        ),
                        if (inventoryId != null) ...[
                          const Gap(4),
                          Text(
                            'Inventory #$inventoryId',
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: onyx.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Gap(12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: onyx.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock will be added to',
                          style: GoogleFonts.lexend(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: onyx.withOpacity(0.45),
                            letterSpacing: 0.7,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          hubDisplayName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: onyx,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (previewMismatch) ...[
                    const Gap(12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        'You are previewing "$previewHubName", but saving will still apply to "$hubDisplayName".',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: onyx.withOpacity(0.84),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                  const Gap(12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: onyx.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add stock amounts',
                          style: GoogleFonts.lexend(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: onyx.withOpacity(0.45),
                            letterSpacing: 0.7,
                          ),
                        ),
                        const Gap(10),
                        Row(
                          children: [
                            Expanded(
                              child: _stockBucketTile(
                                label: 'Good',
                                value: goodQty,
                                bg: const Color(0xFFECFDF3),
                                border: const Color(0xFFA7F3D0),
                                text: const Color(0xFF047857),
                                onyx: onyx,
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: _stockBucketTile(
                                label: 'Damaged',
                                value: damagedQty,
                                bg: const Color(0xFFFFF1F2),
                                border: const Color(0xFFFDA4AF),
                                text: const Color(0xFFBE123C),
                                onyx: onyx,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        Row(
                          children: [
                            Expanded(
                              child: _stockBucketTile(
                                label: 'Needs repair',
                                value: maintQty,
                                bg: const Color(0xFFFFFBEB),
                                border: const Color(0xFFFCD34D),
                                text: const Color(0xFFB45309),
                                onyx: onyx,
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: _stockBucketTile(
                                label: 'Lost / missing',
                                value: lostQty,
                                bg: const Color(0xFFF8FAFC),
                                border: const Color(0xFFCBD5E1),
                                text: const Color(0xFF475569),
                                onyx: onyx,
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        Text(
                          'Total: $total units',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: onyx,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(18),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: onyx.withOpacity(0.14)),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.w800,
                              color: onyx.withOpacity(0.62),
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pop(ctx, true),
                          icon: const Icon(Icons.check_circle_rounded, size: 18),
                          label: Text(
                            'Add stock',
                            style: GoogleFonts.lexend(fontWeight: FontWeight.w800),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: onyx,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _stockBucketTile({
  required String label,
  required int value,
  required Color bg,
  required Color border,
  required Color text,
  required Color onyx,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lexend(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: text,
          ),
        ),
        const Gap(4),
        Text(
          '$value',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: onyx,
            height: 1.0,
          ),
        ),
      ],
    ),
  );
}
