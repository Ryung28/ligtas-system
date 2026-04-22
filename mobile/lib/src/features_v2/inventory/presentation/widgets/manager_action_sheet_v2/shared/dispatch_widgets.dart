import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_controller.dart';
import 'form_fields.dart';

/// Return-date toggle used by both HandoverForm and ReserveForm.
class ReturnScheduleRow extends ConsumerWidget {
  final InventoryItem item;

  const ReturnScheduleRow({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentinel = Theme.of(context).sentinel;
    final s = ref.watch(managerActionControllerProvider(item));
    final ctrl = ref.read(managerActionControllerProvider(item).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RETURN SCHEDULE',
          style: GoogleFonts.lexend(
              fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.carbonGray),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: sentinel.containerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'Anytime',
                style: GoogleFonts.lexend(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.onyxBlack),
              ),
              Switch.adaptive(
                value: s.isDateReturn,
                onChanged: ctrl.toggleDateReturn,
                activeColor: sentinel.primary,
              ),
              Text(
                'Specific Date',
                style: GoogleFonts.lexend(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.onyxBlack),
              ),
              if (s.isDateReturn)
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) ctrl.setExpectedReturnDate(d);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      s.expectedReturnDate == null
                          ? 'Select Date'
                          : '${s.expectedReturnDate!.day}/${s.expectedReturnDate!.month}',
                      style: GoogleFonts.lexend(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: sentinel.primary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Audit sign-off block (Approved By + Released By) used by both Handover and
/// Reserve forms. Receives already-initialised controllers from its parent so
/// initState seeding only happens once.
class DispatchSignOffBlock extends StatelessWidget {
  final TextEditingController approvedCtrl;
  final TextEditingController releasedCtrl;
  final ValueChanged<String> onApprovedChanged;
  final ValueChanged<String> onReleasedChanged;

  const DispatchSignOffBlock({
    super.key,
    required this.approvedCtrl,
    required this.releasedCtrl,
    required this.onApprovedChanged,
    required this.onReleasedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sentinel.containerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sentinel.navy.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 14, color: sentinel.primary),
              const Gap(8),
              Text(
                'DISPATCH SIGN-OFF',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: sentinel.navy,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const Gap(16),
          SheetTextField(
            label: 'APPROVED BY',
            hint: 'Name of Approver',
            controller: approvedCtrl,
            onChanged: onApprovedChanged,
          ),
          const Gap(12),
          SheetTextField(
            label: 'RELEASED BY (SESSION)',
            hint: 'Your Name',
            controller: releasedCtrl,
            onChanged: onReleasedChanged,
          ),
        ],
      ),
    );
  }
}
