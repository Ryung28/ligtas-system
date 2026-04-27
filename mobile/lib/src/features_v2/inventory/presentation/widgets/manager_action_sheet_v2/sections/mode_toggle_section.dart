import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_controller.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_mode.dart';
import 'package:mobile/src/features_v2/inventory/presentation/widgets/action_sheet_components.dart';

/// 2-button mode toggle for Shelves (Identity / Restock only).
/// Delegates to the existing [ActionSheetToggleBar] for visual consistency
/// with the original sheet. Mode changes go through the controller only.
class ModeToggleSection extends ConsumerWidget {
  final InventoryItem item;

  const ModeToggleSection({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentinel = Theme.of(context).sentinel;
    final mode = ref.watch(
      managerActionControllerProvider(item).select((s) => s.mode),
    );
    final ctrl = ref.read(managerActionControllerProvider(item).notifier);

    // Shelves flow no longer exposes direct Hand Over / Reserve actions.
    final sanitizedMode =
        (mode == ManagerMode.handover || mode == ManagerMode.reserve)
            ? ManagerMode.edit
            : mode;
    return ActionSheetToggleBar(
      currentMode: sanitizedMode,
      onModeSelected: ctrl.setMode,
      sentinel: sentinel,
    );
  }
}
