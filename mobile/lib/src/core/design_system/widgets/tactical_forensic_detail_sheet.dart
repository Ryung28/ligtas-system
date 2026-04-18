import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/features_v2/inventory/presentation/widgets/tactical_asset_image.dart';
import 'package:mobile/src/features/navigation/providers/navigation_provider.dart';

/// 🛡️ TACTICAL FORENSIC DETAIL SHEET: UNIFIED COMMAND VIEW (V6)
/// Compressed Bento-style layout with a Large Hero Asset Showcase.
/// Enhanced with Visual Zoning and Twin-Cell row capabilities.
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
  final String? categoryLabel;
  
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
    this.categoryLabel,
    this.actionHub,
    this.heroTagPrefix,
  });

  /// 🛡️ PROTECTED INVOCATION: Orchestrates dock suppression and modal lifecycle.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetRef ref,
    required String id,
    required String title,
    String? referenceId,
    required String statusLabel,
    required Color accentColor,
    bool isAlertStatus = false,
    required IconData statusIcon,
    String? imageUrl,
    int? assetId,
    String? imagePath,
    required List<DetailRowData> details,
    String? purpose,
    ForensicEvidence? forensicEvidence,
    String? analystNotes,
    String? categoryLabel,
    Widget? actionHub,
    String? heroTagPrefix,
  }) async {
    // 1. Suppress global navigation dock
    ref.read(isDockSuppressedProvider.notifier).state = true;

    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true, // 🛡️ SENIOR FIX: Native OS status bar protection
      backgroundColor: Colors.transparent,
      builder: (context) => TacticalForensicDetailSheet(
        id: id,
        title: title,
        referenceId: referenceId,
        statusLabel: statusLabel,
        accentColor: accentColor,
        isAlertStatus: isAlertStatus,
        statusIcon: statusIcon,
        imageUrl: imageUrl,
        assetId: assetId,
        imagePath: imagePath,
        details: details,
        purpose: purpose,
        forensicEvidence: forensicEvidence,
        analystNotes: analystNotes,
        categoryLabel: categoryLabel,
        actionHub: actionHub,
        heroTagPrefix: heroTagPrefix,
      ),
    );

    // 2. Restore navigation dock awareness
    ref.read(isDockSuppressedProvider.notifier).state = false;
    
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroTag = heroTagPrefix != null ? '$heroTagPrefix-img-$id' : 'img-$id';

    // 🛡️ REFINEMENT LOGIC: Group details into logical Bento Zones
    final Map<String?, List<DetailRowData>> zones = {};
    for (var d in details) {
      zones.putIfAbsent(d.zone, () => []).add(d);
    }

    return Container(
      clipBehavior: Clip.antiAlias, // 🛡️ SENIOR FIX: Perfect rounded corner rendering
      decoration: const BoxDecoration(
        color: Color(0xFFF2F4F8), // 🛡️ GLOBAL CANVAS: SOFT DEPTH BASE
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. STABLE HERO HEADER ──
          // Reverted to SliverToBoxAdapter for perfect Hero animation integrity
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: TacticalAssetImage(
                      assetId: assetId,
                      path: imagePath ?? imageUrl,
                      width: double.infinity,
                      height: 240, // 🛡️ STABLE LANDMARK: Reliable, consistent height
                      borderRadius: 0,
                      fit: BoxFit.cover,
                      fallbackIcon: statusIcon,
                      fallbackColor: accentColor,
                    ),
                  ),
                ),
                // Floating Status Badge
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF001A33).withOpacity(0.08), 
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Text(
                      statusLabel.toUpperCase(),
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: accentColor, 
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                // Drag Handle
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. DATA SURFACE ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // IDENTITY HEADER
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 24, // 🛡️ DENSITY: Slightly smaller title
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF001A33),
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),
                const Gap(8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                    ),
                    const Gap(8),
                    Text(
                      categoryLabel ?? 'Operational Resource', 
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const Gap(12), // 🛡️ COMPACT: Snaps the action hub closer to the identity header

                // 🏗️ BENTO GRID GENERATOR
                ...zones.entries.map((entry) => _buildBentoCard(context, entry.key, entry.value)),

                // PURPOSE BLOCK (If exists)
                if (purpose != null) _buildBentoCard(context, 'Objective', [
                   DetailRowData(icon: Icons.notes_rounded, label: 'SERVICE PURPOSE', value: purpose!),
                ]),

                // FORENSIC EVIDENCE (If exists)
                if (forensicEvidence != null) _buildForensicEvidenceCard(),

                // ANALYST NOTES
                if (analystNotes != null) _buildNotesCard(),

                // ── 🛡️ ACTION HUB (Fused into Scroll Layer) ──
                if (actionHub != null) ...[
                  const Gap(16),
                  actionHub!,
                ],

                const Gap(8),
              ]),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildBentoCard(BuildContext context, String? zone, List<DetailRowData> zDetails) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12), // 🛡️ COMPACT: Tighter margins
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), // 🛡️ COMPACT: Tighter internal padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001A33).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                _getZoneIcon(zone),
                size: 14, // 🛡️ COMPACT: Slightly smaller icons
                color: const Color(0xFF64748B),
              ),
              const Gap(8),
              Text(
                (zone ?? 'Details').toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B), // Soft header
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const Gap(12),
          _buildZoneContent(zDetails),
        ],
      ),
    );
  }

  Widget _buildForensicEvidenceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001A33).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_recording_rounded, size: 18, color: Color(0xFF001A33)),
              const Gap(10),
              Text(
                'FORENSIC EVIDENCE',
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF001A33),
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: TacticalAssetImage(
                        path: forensicEvidence!.evidenceImageUrl,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Gap(6),
                    Text('CAPTURE', style: GoogleFonts.lexend(fontSize: 8, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: TacticalAssetImage(
                        path: forensicEvidence!.referenceImageUrl,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Gap(6),
                    Text('CATALOG', style: GoogleFonts.lexend(fontSize: 8, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
     return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001A33).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ANALYST FIELD LOG',
            style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 0.5),
          ),
          const Gap(8),
          Text(
            analystNotes!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getZoneIcon(String? zone) {
    if (zone == null) return Icons.info_outline_rounded;
    final z = zone.toLowerCase();
    if (z.contains('personnel') || z.contains('user')) return Icons.person_rounded;
    if (z.contains('transaction') || z.contains('audit')) return Icons.receipt_long_rounded;
    if (z.contains('stock') || z.contains('ledger')) return Icons.inventory_2_rounded;
    return Icons.grid_view_rounded;
  }

  Widget _buildZoneContent(List<DetailRowData> zoneDetails) {
    // Twin-cell logic: Pair items that are marked as small
    final List<Widget> rows = [];
    
    for (int i = 0; i < zoneDetails.length; i++) {
      final current = zoneDetails[i];
      
      // If current is small and there's another small one next, pair them
      if (current.isHalfWidth && i + 1 < zoneDetails.length && zoneDetails[i + 1].isHalfWidth) {
        final next = zoneDetails[i + 1];
        rows.add(IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: _buildDetailRow(
                icon: current.icon, 
                label: current.label, 
                value: current.value, 
                valueColor: current.valueColor,
                trailing: current.trailing,
                useDivider: false, 
                padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4)
              )),
              const VerticalDivider(width: 1, color: Color(0xFFE2E8F0), indent: 12, endIndent: 12),
              Expanded(child: _buildDetailRow(
                icon: next.icon, 
                label: next.label, 
                value: next.value, 
                valueColor: next.valueColor,
                trailing: next.trailing,
                useDivider: false, 
                padding: const EdgeInsets.only(left: 8, right: 12, top: 4, bottom: 4)
              )),
            ],
          ),
        ));
        i++; // Skip next since we paired it
      } else {
        // Build full width
        rows.add(_buildDetailRow(
          icon: current.icon, 
          label: current.label, 
          value: current.value,
          valueColor: current.valueColor,
          trailing: current.trailing,
          useDivider: i < zoneDetails.length - 1,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ));
      }
    }
    
    return Column(children: rows);
  }


  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Widget? trailing,
    bool useDivider = false,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 4), // 🛡️ COMPACT: Ultra-tight
  }) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF001A33)),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.lexend(
                    fontSize: 8, // 🛡️ COMPACT: Micro-label
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? const Color(0xFF001A33),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
class DetailRowData {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final String? zone; // Visual grouping
  final bool isHalfWidth; // Enable side-by-side pairing
  final Widget? trailing; // Extra info (icons, badges)

  const DetailRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.zone,
    this.isHalfWidth = false,
    this.trailing,
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
