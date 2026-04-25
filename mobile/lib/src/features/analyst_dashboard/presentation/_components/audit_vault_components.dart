import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/activity_event.dart';
import '../../../../core/design_system/app_theme.dart';
import '../../../../features_v2/loans/domain/entities/loan_item.dart';
import '../../../../features_v2/loans/presentation/providers/loan_provider.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../../../features_v2/inventory/presentation/providers/inventory_provider.dart';
import '../../../../features_v2/inventory/presentation/widgets/tactical_asset_image.dart';
import '../../../../core/design_system/widgets/tactical_forensic_card.dart';
import '../../../../core/design_system/widgets/tactical_image_viewer.dart';
import '../../../../core/design_system/widgets/tactical_forensic_detail_sheet.dart';
import '../controllers/analyst_dashboard_controller.dart';
import '../../../../core/utils/storage_location_labels.dart';

String? _displayBorrowSite(ActivityEvent e) {
  final raw = e.locationSource ?? e.locationTarget;
  if (raw == null) return null;
  final t = raw.trim();
  if (t.isEmpty) return null;
  return formatStorageLocationLabel(t);
}

/// 🏛️ AUDIT VAULT COMPONENT HUB
/// Centralized forensic UI organisms for the Analyst Audit System.
/// Extracted from AnalystHistoryScreen to maintain Architectural Integrity.

/// ── COMPACT FORENSIC ROW ──
class AuditLedgerRow extends ConsumerWidget {
  final ActivityEvent event;
  final SentinelColors sentinel;

  const AuditLedgerRow({super.key, required this.event, required this.sentinel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borrowSite = _displayBorrowSite(event);
    final statusColor = _getSoftStatusColor(event.type);
    final iconColor = _getStatusColor(event.type);
    final quantityColor = _getQuantityColor(event.type);
    
    // 🛡️ IMAGE RESOLUTION: Forensic Evidence -> Inventory Reference (Paths only)
    final String? resolvedPath = event.evidencePath ?? event.referencePath;
    final int? resolvedAssetId = event.assetId;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showCommandDetailSheet(context, ref, event);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. TACTICAL ASSET IMAGE (With Preview) ──
            GestureDetector(
              onTap: (resolvedPath != null || resolvedAssetId != null)
                  ? () {
                      HapticFeedback.mediumImpact();
                      // We still need a URL for the viewer, so we resolve it once here
                      final storage = Supabase.instance.client.storage;
                      String viewerUrl = '';
                      if (resolvedPath != null) {
                        final bucket = event.evidencePath != null ? 'forensic-evidence' : 'item-images';
                        viewerUrl = storage.from(bucket).getPublicUrl(resolvedPath);
                      } else if (resolvedAssetId != null) {
                         final imageMap = ref.read(inventoryImageMapProvider);
                         final catalogPath = imageMap[resolvedAssetId] ?? '';
                         if (catalogPath.isNotEmpty) {
                           viewerUrl = catalogPath.startsWith('http') 
                              ? catalogPath 
                              : storage.from('item-images').getPublicUrl(catalogPath);
                         }
                      }

                      if (viewerUrl.isNotEmpty) {
                        TacticalImageViewer.show(
                          context,
                          url: viewerUrl,
                          title: event.title,
                          heroTag: 'audit-img-${event.id}',
                        );
                      }
                    }
                  : null,
              child: Hero(
                tag: 'audit-img-${event.id}',
                child: TacticalAssetImage(
                  path: resolvedPath,
                  assetId: resolvedAssetId,
                  size: 48,
                  borderRadius: 12,
                ),
              ),
            ),
            const Gap(16),

            // ── 2. CORE CONTENT ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.neutralGray900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (borrowSite != null) ...[
                    const Gap(4),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 13, color: AppTheme.neutralGray400),
                        const Gap(4),
                        Expanded(
                          child: Text(
                            borrowSite,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.neutralGray500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Gap(4),
                  // Borrower Name (Primary Identifier)
                  if (event.actorName != null)
                    Text(
                      event.actorName!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.neutralGray700,
                      ),
                    ),
                  // Status Name (Directly below name)
                  Text(
                    _getStatusText(event.type),
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _getStatusColor(event.type),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),

            // ── 3. TEMPORAL & QUANTITY METADATA ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  event.timeDisplay,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.neutralGray400,
                  ),
                ),
                const Gap(8),
                if (event.quantityDelta != null)
                  Text(
                    event.quantityDelta!,
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: quantityColor,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCommandDetailSheet(BuildContext context, WidgetRef ref, ActivityEvent event) async {
    await CommandDetailSheet.show(context, ref, event);
  }
}

/// ── TOP-LEVEL LOGISTICAL HELPERS ──

Color _getSoftStatusColor(EventType type) {
  switch (type) {
    case EventType.assetOut: return const Color(0xFF3B82F6);
    case EventType.assetIn: return const Color(0xFF10B981);
    case EventType.requisitionApproved: return const Color(0xFF10B981);
    case EventType.securityTrigger: return const Color(0xFFEF4444);
    case EventType.requisitionRejected: return const Color(0xFF64748B);
    case EventType.systemSync: return const Color(0xFF94A3B8);
    case EventType.reserved: return const Color(0xFFF59E0B);
    case EventType.maintenance: return const Color(0xFFF59E0B);
    case EventType.requisitionDenied: return const Color(0xFFEF4444);
    case EventType.mixed: return const Color(0xFF64748B);
  }
}

Color _getQuantityColor(EventType type) {
  switch (type) {
    case EventType.assetIn:
    case EventType.requisitionApproved:
      return const Color(0xFF10B981); // Positive change (green)
    case EventType.assetOut:
    case EventType.requisitionDenied:
    case EventType.requisitionRejected:
      return const Color(0xFFEF4444); // Negative change (red)
    case EventType.maintenance:
      return const Color(0xFFF59E0B); // Caution/Alert (orange)
    case EventType.mixed:
      return const Color(0xFF64748B); // Neutral
    default:
      return AppTheme.neutralGray900;
  }
}

/// Helper to improve readability by converting ALL CAPS or snake_case to Title Case
String _toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

Color _getStatusColor(EventType type) {
  switch (type) {
    case EventType.assetOut: return const Color(0xFF3B82F6);
    case EventType.assetIn: return const Color(0xFF10B981);
    case EventType.requisitionApproved: return const Color(0xFF10B981);
    case EventType.securityTrigger: return const Color(0xFFEF4444);
    case EventType.requisitionRejected: return const Color(0xFF64748B);
    case EventType.systemSync: return const Color(0xFF94A3B8);
    case EventType.reserved: return const Color(0xFFF59E0B);
    case EventType.maintenance: return const Color(0xFFF59E0B);
    case EventType.requisitionDenied: return const Color(0xFFEF4444);
    case EventType.mixed: return const Color(0xFF64748B);
  }
}

IconData _getIcon(EventType type) {
  switch (type) {
    case EventType.assetOut: return Icons.logout_rounded;
    case EventType.assetIn: return Icons.login_rounded;
    case EventType.requisitionApproved: return Icons.fact_check_rounded;
    case EventType.systemSync: return Icons.cloud_done_rounded;
    case EventType.reserved: return Icons.event_available_rounded;
    case EventType.securityTrigger: return Icons.security_rounded;
    case EventType.requisitionRejected: return Icons.rule_rounded;
    case EventType.maintenance: return Icons.handyman_rounded;
    case EventType.requisitionDenied: return Icons.gavel_rounded;
    case EventType.mixed: return Icons.sync_problem_rounded;
  }
}

String _getStatusText(EventType type) {
  switch (type) {
    case EventType.assetOut: return 'BORROWED';
    case EventType.assetIn: return 'RETURNED';
    case EventType.requisitionApproved: return 'VERIFIED';
    case EventType.systemSync: return 'SYNCED';
    case EventType.reserved: return 'RESERVED';
    case EventType.securityTrigger: return 'SECURITY TRIGGER';
    case EventType.requisitionRejected: return 'REJECTED';
    case EventType.maintenance: return 'MAINTENANCE';
    case EventType.requisitionDenied: return 'DENIED';
    case EventType.mixed: return 'MIXED';
  }
}

String _getActorLabel(EventType type) {
  switch (type) {
    case EventType.requisitionApproved: return 'APPROVED BY';
    case EventType.requisitionRejected: return 'REJECTED BY';
    case EventType.maintenance: return 'ASSIGNEE';
    case EventType.requisitionDenied: return 'DENIED BY';
    case EventType.mixed: return 'MULTIPLE ACTORS';
    default: return 'REQUESTER';
  }
}

/// ── TACTICAL ASSET BLUEPRINT ──
/// Renders a premium, minimalist "Obsidian Well" placeholder.
class TacticalAssetBlueprint extends StatelessWidget {
  final String imageUrl;
  final SentinelColors sentinel;
  final double size;

  const TacticalAssetBlueprint({
    super.key, 
    required this.imageUrl, 
    required this.sentinel,
    this.size = 54,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white, // High-Contrast Clean White
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutralGray200, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: const Color(0xFFE2E8F0),
                highlightColor: Colors.white,
                child: Container(color: Colors.white),
              ),
            )
          : Center(
              child: Icon(
                Icons.category_rounded, // High-Contrast Black Ghost
                size: size * 0.45, 
                color: Colors.black,
              ),
            ),
      ),
    );
  }
}

/// ── FORENSIC COMMAND DETAIL SHEET ──
class CommandDetailSheet extends ConsumerWidget {
  final ActivityEvent event;

  const CommandDetailSheet({super.key, required this.event});

  /// 🛡️ PROTECTED INVOCATION: Orchestrates dock suppression for forensic logs.
  static Future<T?> show<T>(BuildContext context, WidgetRef ref, ActivityEvent event) async {
    ref.read(isDockSuppressedProvider.notifier).state = true;
    
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommandDetailSheet(event: event),
    );

    ref.read(isDockSuppressedProvider.notifier).state = false;
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLoans = ref.watch(managerLoansNotifierProvider).valueOrNull ?? [];
    final associatedLoan = allLoans.where((l) => l.id == event.referenceId).firstOrNull;
    final sentinelColor = _getStatusColor(event.type);
    final statusText = _getStatusText(event.type);
    final isVerified = event.verifiedAt != null;
    final borrowSiteRow = _displayBorrowSite(event);

    return TacticalForensicDetailSheet(
      id: event.id,
      title: event.title,
      referenceId: event.referenceId,
      assetId: event.assetId,
      statusLabel: statusText.toUpperCase(),
      accentColor: sentinelColor,
      statusIcon: _getIcon(event.type),
      imagePath: event.evidencePath ?? event.referencePath,
      heroTagPrefix: 'audit',
      analystNotes: event.notes,
      forensicEvidence: (event.evidencePath != null && event.referencePath != null)
          ? ForensicEvidence(
              evidenceImageUrl: event.evidencePath!,
              referenceImageUrl: event.referencePath!,
            )
          : null,
      details: [
        DetailRowData(
          icon: Icons.person_rounded,
          label: _getActorLabel(event.type),
          value: event.actorName ?? 'System Override',
          zone: 'Personnel',
        ),
        if (borrowSiteRow != null)
          DetailRowData(
            icon: Icons.warehouse_outlined,
            label: 'BORROW SITE',
            value: borrowSiteRow,
            zone: 'Transaction Details',
            isHalfWidth: false,
          ),
        if (event.borrowerOrganization != null)
          DetailRowData(
            icon: Icons.business_center_rounded,
            label: 'ORGANIZATION',
            value: event.borrowerOrganization!,
            zone: 'Personnel',
          ),
        if (event.borrowerContact != null)
          DetailRowData(
            icon: Icons.phone_android_rounded,
            label: 'CONTACT',
            value: event.borrowerContact!,
            zone: 'Personnel',
          ),
        if (event.approvedByName != null)
          DetailRowData(
            icon: Icons.gavel_rounded,
            label: 'APPROVED BY',
            value: event.approvedByName!,
            zone: 'Transaction Details',
            isHalfWidth: true,
          ),
        if (event.releasedByName != null)
          DetailRowData(
            icon: Icons.hail_rounded,
            label: 'HANDED BY',
            value: event.releasedByName!,
            zone: 'Transaction Details',
            isHalfWidth: false, // Changed to false to prevent truncation
          ),
        DetailRowData(
          icon: Icons.timer_rounded,
          label: 'TIME OCCURRED',
          value: DateFormat('MMMM dd, yyyy, hh:mm a').format(event.timestamp),
          zone: 'Transaction Details',
          isHalfWidth: false, // Make it full width since it's long now
        ),
        if (event.quantityDelta != null)
          DetailRowData(
            icon: Icons.inventory_2_rounded,
            label: 'QUANTITY',
            value: event.quantityDelta!,
            zone: 'Transaction Details',
            isHalfWidth: true,
          ),
        if (isVerified)
          DetailRowData(
            icon: Icons.verified_user_rounded,
            label: 'VERIFIED AT',
            value: DateFormat('MMMM dd, yyyy, hh:mm a').format(event.verifiedAt!),
            zone: 'Transaction Details',
          ),
      ],
      actionHub: associatedLoan != null
          ? _buildTacticalActions(context, ref, associatedLoan)
          : _buildDismissAction(context),
    );
  }

  Widget _buildDismissAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: const BorderSide(color: AppTheme.neutralGray300),
        ),
        child: Text('DISMISS', style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.neutralGray700)),
      ),
    );
  }


  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'excellent': return AppTheme.successGreen;
      case 'good': return const Color(0xFF3B82F6);
      case 'damaged': return AppTheme.errorRed;
      case 'lost': return Colors.black;
      default: return AppTheme.neutralGray500;
    }
  }

  Widget _buildTacticalActions(BuildContext context, WidgetRef ref, LoanItem loan) {
    final bool isPending = loan.status == LoanStatus.pending;
    final bool isApproved = loan.status == LoanStatus.active && loan.handedBy == null;
    final bool isActive = loan.status == LoanStatus.active && loan.handedBy != null;

    return Column(
      children: [
        if (isPending)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: const BorderSide(color: AppTheme.errorRed)),
                  child: Text('REJECT', style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.errorRed)),
                ),
              ),
              const Gap(12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(managerLoansNotifierProvider.notifier).approveRequest(loan.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text('APPROVE', style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
                ),
              ),
            ],
          ),
        if (isApproved)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(managerLoansNotifierProvider.notifier).confirmHandoff(loan.id);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.handshake_rounded, size: 18, color: Colors.white),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              label: Text('CONFIRM HANDOFF', style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
            ),
          ),
        if (isActive)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => showDialog(context: context, builder: (context) => ReturnAssessmentDialog(loan: loan)),
              icon: const Icon(Icons.assignment_returned_rounded, size: 18, color: Colors.white),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001A33), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              label: Text('CONFIRM RETURN', style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
            ),
          ),
      ],
    );
  }
}

/// ── RETURN ASSESSMENT DIALOG ──
class ReturnAssessmentDialog extends StatefulWidget {
  final LoanItem loan;
  const ReturnAssessmentDialog({super.key, required this.loan});

  @override
  State<ReturnAssessmentDialog> createState() => _ReturnAssessmentDialogState();
}

class _ReturnAssessmentDialogState extends State<ReturnAssessmentDialog> {
  String _condition = 'Excellent';
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text('Logistical Verification', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.neutralGray900)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ASSESS CONDITION', style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.neutralGray400, letterSpacing: 1.0)),
          const Gap(12),
          DropdownButtonFormField<String>(
            value: _condition,
            decoration: InputDecoration(filled: true, fillColor: AppTheme.neutralGray50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            items: ['Excellent', 'Good', 'Damaged', 'Lost'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)))).toList(),
            onChanged: (v) => setState(() => _condition = v!),
          ),
          const Gap(20),
          Text('SERVICEABILITY NOTES', style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.neutralGray400, letterSpacing: 1.0)),
          const Gap(12),
          TextField(controller: _notesController, maxLines: 3, decoration: InputDecoration(filled: true, fillColor: AppTheme.neutralGray50, hintText: 'Record audit notes here...', hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.neutralGray400), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        Consumer(builder: (context, ref, _) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(managerLoansNotifierProvider.notifier).confirmReturn(widget.loan.id, _condition, _notesController.text.isEmpty ? null : _notesController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text('FINALIZE RETURN', style: GoogleFonts.lexend(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
            ),
          );
        }),
      ],
    );
  }
}
