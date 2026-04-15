import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/features_v2/inventory/presentation/widgets/tactical_asset_image.dart';
import '../app_theme.dart';
import 'tactical_image_viewer.dart';

/// 🛡️ TACTICAL FORENSIC DETAIL SHEET: UNIFIED COMMAND VIEW (V5)
/// Compressed Bento-style layout with a Large Hero Asset Showcase.
class TacticalForensicDetailSheet extends ConsumerWidget {
  final String id;
  final String title;
  final String? referenceId;
  final String statusLabel;
  final Color accentColor;
  final bool isAlertStatus;
  final IconData statusIcon;
  final String? imageUrl;
  final int? assetId;
  final String? imagePath;
  
  final List<DetailRowData> details;
  final String? purpose;
  
  // Forensic Layer (Manager-Only)
  final ForensicEvidence? forensicEvidence;
  final String? analystNotes;
  
  final Widget? actionHub;
  final String? heroTagPrefix;

  const TacticalForensicDetailSheet({
    super.key,
    required this.id,
    required this.title,
    this.referenceId,
    required this.statusLabel,
    required this.accentColor,
    this.isAlertStatus = false,
    required this.statusIcon,
    this.imageUrl,
    this.assetId,
    this.imagePath,
    required this.details,
    this.purpose,
    this.forensicEvidence,
    this.analystNotes,
    this.actionHub,
    this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final heroTag = heroTagPrefix != null ? '$heroTagPrefix-img-$id' : 'img-$id';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 1. HERO ASSET SHOWCASE (Big Image) ──
          Stack(
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: TacticalAssetImage(
                    assetId: assetId,
                    path: imagePath ?? imageUrl,
                    width: double.infinity,
                    height: 200, // Slightly taller for Hero impact
                    borderRadius: 0,
                    fit: BoxFit.cover,
                    fallbackIcon: statusIcon,
                    fallbackColor: accentColor,
                  ),
                ),
              ),
              // Drag Handle Overlay
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 2. IDENTITY BLOCK (Compact) ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.lexend(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        if (referenceId != null) ...[
                          const Gap(8),
                          Text(
                            referenceId!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Gap(16),

                    // ── 3. STATUS STRIP (Neutral / Plain Words) ──
                    _buildStatusHeader(statusLabel, statusIcon),
                    const Gap(16),

                    // ── 4. LOGISTICAL BENTO BOX (Compressed) ──
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: Column(
                        children: [
                          ...details.asMap().entries.map((entry) {
                            final index = entry.key;
                            final detail = entry.value;
                            return Column(
                              children: [
                                _buildDetailRow(
                                  icon: detail.icon,
                                  label: detail.label,
                                  value: detail.value,
                                ),
                                if (index < details.length - 1)
                                  const Divider(height: 1, color: Color(0xFFE2E8F0), indent: 48),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),

                    // ── 5. MISSION PURPOSE (Compressed) ──
                    if (analystNotes != null || purpose != null) ...[
                      const Gap(16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              analystNotes != null ? 'Analyst Notes' : 'Mission Purpose',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              analystNotes ?? purpose!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF475569),
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── 6. ACTION HUB ──
                    if (actionHub != null) ...[
                      const Gap(24),
                      actionHub!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(String label, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 18),
          const Gap(12),
          Text(
            'Status:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const Gap(6),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const Gap(16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailRowData {
  final IconData icon;
  final String label;
  final String value;

  const DetailRowData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class ForensicEvidence {
  final String evidenceImageUrl;
  final String referenceImageUrl;

  const ForensicEvidence({
    required this.evidenceImageUrl,
    required this.referenceImageUrl,
  });
}
