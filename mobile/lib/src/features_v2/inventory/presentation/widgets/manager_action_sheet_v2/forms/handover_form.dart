import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_controller.dart';
import 'package:mobile/src/features_v2/inventory/presentation/widgets/action_sheet_components.dart';
import '../shared/form_fields.dart';
import '../shared/dispatch_widgets.dart';

/// Dispatch / Hand Over form. Captures recipient info, quantity, approvals,
/// and an optional return date. No business logic — all state goes to
/// [ManagerActionController] via typed setter calls.
class HandoverForm extends ConsumerStatefulWidget {
  final InventoryItem item;

  const HandoverForm({super.key, required this.item});

  @override
  ConsumerState<HandoverForm> createState() => _HandoverFormState();
}

class _HandoverFormState extends ConsumerState<HandoverForm> {
  late final TextEditingController _recipientCtrl;
  late final TextEditingController _officeCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _approvedCtrl;
  late final TextEditingController _releasedCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(managerActionControllerProvider(widget.item));
    _recipientCtrl = TextEditingController(text: s.recipientName);
    _officeCtrl = TextEditingController(text: s.recipientOffice);
    _contactCtrl = TextEditingController(text: s.recipientContact);
    _approvedCtrl = TextEditingController(text: s.approvedBy);
    _releasedCtrl = TextEditingController(text: s.releasedBy);
  }

  @override
  void dispose() {
    _recipientCtrl.dispose();
    _officeCtrl.dispose();
    _contactCtrl.dispose();
    _approvedCtrl.dispose();
    _releasedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(managerActionControllerProvider(widget.item).notifier);
    final quantity = ref.watch(
      managerActionControllerProvider(widget.item).select((s) => s.quantity),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'HOW MANY?',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.onyxBlack,
              ),
            ),
            const Spacer(),
            QuantitySelector(
              quantity: quantity,
              onChanged: ctrl.setQuantity,
              max: 999,
            ),
          ],
        ),
        const Gap(24),
        SheetTextField(
          label: 'RECIPIENT / BORROWER',
          hint: 'Full Name',
          controller: _recipientCtrl,
          onChanged: ctrl.setRecipientName,
        ),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: SheetTextField(
                label: 'OFFICE',
                hint: 'e.g. MDRRMO',
                controller: _officeCtrl,
                onChanged: ctrl.setRecipientOffice,
              ),
            ),
            const Gap(10),
            Expanded(
              child: SheetTextField(
                label: 'CONTACT #',
                hint: 'Optional',
                controller: _contactCtrl,
                keyboardType: TextInputType.phone,
                onChanged: ctrl.setRecipientContact,
              ),
            ),
          ],
        ),
        const Gap(16),
        ReturnScheduleRow(item: widget.item),
        const Gap(16),
        DispatchSignOffBlock(
          approvedCtrl: _approvedCtrl,
          releasedCtrl: _releasedCtrl,
          onApprovedChanged: ctrl.setApprovedBy,
          onReleasedChanged: ctrl.setReleasedBy,
        ),
        const Gap(24),
      ],
    );
  }
}
