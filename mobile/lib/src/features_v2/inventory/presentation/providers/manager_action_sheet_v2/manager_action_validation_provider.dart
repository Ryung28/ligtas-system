import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'manager_action_controller.dart';
import 'manager_action_mode.dart';

part 'manager_action_validation_provider.g.dart';

/// Single, computed gate for submit eligibility.
/// Every mode has its own required-field set derived from the controller state.
/// The submit button only reads this — it has zero validation logic of its own.
@riverpod
bool managerActionCanSubmit(ManagerActionCanSubmitRef ref, InventoryItem item) {
  final s = ref.watch(managerActionControllerProvider(item));
  if (s.isSubmitting || s.isEditLoading) return false;

  switch (s.mode) {
    case ManagerMode.restock:
      final total = s.qtyGood + s.qtyDamaged + s.qtyMaintenance + s.qtyLost;
      return total >= 1;

    case ManagerMode.edit:
      final hasLocation =
          s.storageLocation.trim().isNotEmpty || s.locationRegistryId != null;
      final total = s.qtyGood + s.qtyDamaged + s.qtyMaintenance + s.qtyLost;
      return s.note.trim().isNotEmpty &&
          s.itemName.trim().isNotEmpty &&
          s.category.trim().isNotEmpty &&
          s.targetStock > 0 &&
          hasLocation &&
          total >= 1;

    case ManagerMode.handover:
      return s.note.trim().isNotEmpty &&
          s.recipientName.trim().isNotEmpty &&
          s.recipientOffice.trim().isNotEmpty &&
          s.approvedBy.trim().isNotEmpty &&
          s.releasedBy.trim().isNotEmpty;

    case ManagerMode.reserve:
      return s.note.trim().isNotEmpty &&
          s.recipientName.trim().isNotEmpty &&
          s.recipientOffice.trim().isNotEmpty &&
          s.approvedBy.trim().isNotEmpty &&
          s.releasedBy.trim().isNotEmpty &&
          s.pickupScheduledAt != null;
  }
}
