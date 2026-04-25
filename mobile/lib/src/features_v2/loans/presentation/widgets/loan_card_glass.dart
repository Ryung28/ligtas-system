import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/loan_item.dart';
import '../../../../core/design_system/widgets/tactical_image_viewer.dart';
import '../../../../core/utils/storage_utils.dart';

/// My Items card tuned to match the provided UI reference.
class LoanCardGlass extends StatelessWidget {
  final LoanItem loan;
  final VoidCallback onTap;
  final VoidCallback? onReturn;

  const LoanCardGlass({
    super.key,
    required this.loan,
    required this.onTap,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final statusMeta = _statusMeta(loan.status);
    final issuedTime = _formatTimeLabel(loan.borrowDate);
    final resolvedImageUrl = StorageUtils.resolveAssetUrl(loan.imageUrl);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF001A33).withOpacity(0.06),
                offset: const Offset(0, 4),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            children: [
              _buildImageBlock(context, resolvedImageUrl),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            loan.itemName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lexend(
                              fontSize: 17,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF09243E),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusMeta.color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusMeta.label,
                            style: GoogleFonts.lexend(
                              fontSize: 8.5,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    // ── Subtle Divider ──
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: const Color(0xFFF1F4F8),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFFA6AFBB)),
                        const Gap(6),
                        Text(
                          '${loan.quantityBorrowed} Units',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4C5F74),
                          ),
                        ),
                        const Gap(16),
                        const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFFA6AFBB)),
                        const Gap(6),
                        Expanded(
                          child: Text(
                            issuedTime,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6A7D92),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageBlock(BuildContext context, String resolvedImageUrl) {
    final hasImage = resolvedImageUrl.isNotEmpty;
    final heroTag = 'loan_icon_${loan.id}';

    return GestureDetector(
      onTap: hasImage
          ? () => TacticalImageViewer.show(
                context,
                url: resolvedImageUrl,
                title: loan.itemName,
                heroTag: heroTag,
              )
          : null,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F4F8), width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: hasImage
              ? Hero(
                  tag: heroTag,
                  child: Image.network(
                    resolvedImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackImage(),
                  ),
                )
              : _fallbackImage(),
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: const Color(0xFFF0F3F7),
      alignment: Alignment.center,
      child: const Icon(
        Icons.inventory_2_rounded,
        size: 34,
        color: Color(0xFFB3BECB),
      ),
    );
  }

  ({String label, Color color}) _statusMeta(LoanStatus status) {
    switch (status) {
      case LoanStatus.pending:
        return (label: 'PENDING', color: const Color(0xFF8A6514));
      case LoanStatus.overdue:
        return (label: 'OVERDUE', color: const Color(0xFFB42318));
      case LoanStatus.returned:
        return (label: 'RETURNED', color: const Color(0xFF067647));
      case LoanStatus.cancelled:
        return (label: 'CANCELLED', color: const Color(0xFF667085));
      case LoanStatus.staged:
        return (label: 'STAGED', color: const Color(0xFF155EEF));
      case LoanStatus.active:
      default:
        return (label: 'BORROWED', color: const Color(0xFF0B213E));
    }
  }

  String _formatTimeLabel(DateTime dateTime) {
    final now = DateTime.now();
    final onlyDateNow = DateTime(now.year, now.month, now.day);
    final onlyDateInput = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final time = DateFormat('hh:mm a').format(dateTime);

    if (onlyDateInput == onlyDateNow) return '$time Today';
    if (onlyDateInput == onlyDateNow.subtract(const Duration(days: 1))) return '$time Yesterday';
    return '$time ${DateFormat('MMM dd').format(dateTime)}';
  }
}
