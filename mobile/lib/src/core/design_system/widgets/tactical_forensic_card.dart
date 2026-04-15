import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../app_theme.dart';

/// 🛡️ TACTICAL FORENSIC CARD: UNIFIED COMMAND ROW (V4.1)
/// A high-density card restored for full forensic visibility.
/// Used for loan tracking, audit logs, and activity manifests.
class TacticalForensicCard extends StatelessWidget {
  final String id;
  final String title;
  final String statusLabel;
  final Color accentColor;
  final String timestampValue;
  final VoidCallback onTap;
  
  // 🛡️ RESTORED PROPERTIES
  final String? imageUrl;
  final String? referenceId;
  final String? timestampLabel;
  final String? secondaryLabel;
  final String? secondaryValue;
  final VoidCallback? onThumbnailTap;
  final Widget? decisionHub;
  final String? heroTagPrefix;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const TacticalForensicCard({
    super.key,
    required this.id,
    required this.title,
    required this.statusLabel,
    required this.accentColor,
    required this.timestampValue,
    required this.onTap,
    this.imageUrl,
    this.referenceId,
    this.timestampLabel,
    this.secondaryLabel,
    this.secondaryValue,
    this.onThumbnailTap,
    this.decisionHub,
    this.heroTagPrefix,
    this.onActionTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final heroTag = heroTagPrefix != null ? '$heroTagPrefix-img-$id' : 'img-$id';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1), // 🛡️ DEPTH: High-definition boundary
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4), // 🛡️ DEPTH: Crisp micro-lift
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. LARGE ASSET PROFILE (Pillar) ──
                GestureDetector(
                  onTap: onThumbnailTap,
                  child: Hero(
                    tag: heroTag,
                    child: Container(
                      width: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                        child: imageUrl != null && imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => _buildShimmer(),
                                errorWidget: (context, url, error) => _buildPlaceholderIcon(),
                              )
                            : _buildPlaceholderIcon(),
                      ),
                    ),
                  ),
                ),

                // ── 2. DATA MANIFEST COLUMN ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lexend(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const Gap(8),
                            // ── STATUS TAG ──
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFF0F172A), width: 1),
                              ),
                              child: Text(
                                statusLabel,
                                style: GoogleFonts.lexend(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (secondaryValue != null) ...[
                          const Gap(8),
                          Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 12, color: Color(0xFF0F172A)),
                              const Gap(6),
                              Text(
                                secondaryValue!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Spacer(),
                        // ── LOG STAMP & NAVIGATION (Bottom Right Anchor) ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.history_rounded, size: 12, color: Color(0xFF0F172A)),
                            const Gap(6),
                            Text(
                              '${timestampLabel ?? 'LOG'}: $timestampValue',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                                letterSpacing: 0.1,
                              ),
                            ),
                            const Gap(8),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFFE2E8F0), size: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.white,
      child: Container(color: Colors.white),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(Icons.inventory_2_outlined, color: accentColor.withOpacity(0.4), size: 24),
    );
  }
}
