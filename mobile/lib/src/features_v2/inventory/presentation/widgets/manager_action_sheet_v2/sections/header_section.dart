import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/inventory_provider.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_controller.dart';
import 'package:mobile/src/features_v2/inventory/presentation/widgets/action_sheet_components.dart';

/// Wraps the existing [ActionSheetHeader] component and hooks image updates
/// back into the V2 controller. Reads live item name / category from the
/// controller state so edits are reflected immediately in the header.
class HeaderSection extends ConsumerWidget {
  final InventoryItem item;

  const HeaderSection({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentinel = Theme.of(context).sentinel;
    final s = ref.watch(managerActionControllerProvider(item));
    final ctrl = ref.read(managerActionControllerProvider(item).notifier);

    final displayName = s.itemName.trim().isNotEmpty ? s.itemName : item.name;
    final displayCategory = s.category.trim().isNotEmpty ? s.category : item.category;
    final categoryIcon = ref.watch(categoryIconProvider(displayCategory));

    return ActionSheetHeader(
      itemId: item.id,
      imageUrl: s.localImageUrl ?? item.imageUrl ?? '',
      itemName: displayName,
      category: displayCategory,
      categoryIcon: categoryIcon,
      sentinel: sentinel,
      isEditMode: s.mode.index == 3, // edit
      onImageUpdated: (url) {
        ctrl.setLocalImageUrl(url);
        ref.read(inventoryNotifierProvider.notifier).refresh();
      },
    );
  }
}
