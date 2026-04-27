import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_controller.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_mode.dart';
import 'package:mobile/src/features/navigation/providers/navigation_provider.dart';
import 'sections/header_section.dart';
import 'sections/mode_toggle_section.dart';
import 'sections/note_section.dart';
import 'sections/submit_section.dart';
import 'forms/restock_form.dart';
import 'forms/edit_form.dart';

/// Entry point for the V2 Manager Action Sheet.
///
/// Shell only — it owns the scroll container, drag handle, and keyboard inset.
/// All form content and submit logic live in dedicated sub-widgets.
/// No business logic lives here.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (_) => ManagerActionSheetV2(item: item),
/// );
/// ```
class ManagerActionSheetV2 extends ConsumerStatefulWidget {
  final InventoryItem item;

  const ManagerActionSheetV2({super.key, required this.item});

  @override
  ConsumerState<ManagerActionSheetV2> createState() =>
      _ManagerActionSheetV2State();
}

class _ManagerActionSheetV2State extends ConsumerState<ManagerActionSheetV2> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(isDockSuppressedProvider.notifier).state = true;
      ref.read(managerActionControllerProvider(widget.item).notifier).init();
    });
  }

  @override
  void dispose() {
    // 🛡️ DOCK RESTORATION: Handled by PopScope to avoid 'ref used after disposed' race condition.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(isDockSuppressedProvider.notifier).state = false;
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: bottomInset + 24,
          ),
          decoration: BoxDecoration(
            color: sentinel.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Gap(24),
                  HeaderSection(item: widget.item),
                  const Gap(24),
                  ModeToggleSection(item: widget.item),
                  const Gap(24),
                  _ActiveForm(item: widget.item),
                  NoteSection(item: widget.item),
                  const Gap(24),
                  SubmitSection(item: widget.item),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Routes to the correct form widget based on the current mode.
/// Isolated so the shell build method stays under 200 lines.
class _ActiveForm extends ConsumerWidget {
  final InventoryItem item;

  const _ActiveForm({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      managerActionControllerProvider(item).select((s) => s.mode),
    );
    switch (mode) {
      case ManagerMode.restock:
        return RestockForm(item: item);
      case ManagerMode.edit:
        return EditForm(item: item);
      case ManagerMode.handover:
      case ManagerMode.reserve:
        // Shelves sheet keeps dispatch flows in FAB batch UX.
        return EditForm(item: item);
    }
  }
}
