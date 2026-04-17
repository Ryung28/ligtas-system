import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/inventory_provider.dart';
import 'package:mobile/src/features/auth/providers/auth_provider.dart';
import 'manager_action_form_state.dart';
import 'manager_action_mode.dart';

part 'manager_action_controller.g.dart';

/// Orchestrates all state mutations and async actions for the Manager Action
/// Sheet V2. Widgets call setters here — never Supabase directly.
@riverpod
class ManagerActionController extends _$ManagerActionController {
  @override
  ManagerActionFormState build(InventoryItem item) {
    final user = ref.read(currentUserProvider);
    return ManagerActionFormState(
      itemName: item.name,
      category: item.category,
      serial: item.code,
      model: item.modelNumber,
      targetStock: item.targetStock,
      minStock: item.minStockLevel,
      qtyGood: item.availableStock,
      qtyDamaged: item.totalStock - item.availableStock,
      storageLocation: item.location,
      locationRegistryId: item.locationRegistryId,
      releasedBy: user?.displayName ?? '',
    );
  }

  // Hydrate admin fields immediately for restock or edit mode.
  void init() {
    if (state.mode == ManagerMode.restock || state.mode == ManagerMode.edit) {
      _loadEditFields();
    }
  }

  // ── Mode ──────────────────────────────────────────────────────────────────

  void setMode(ManagerMode mode) {
    state = state.copyWith(mode: mode, submitError: null);
    // Both restock and edit need real bucket values from the DB.
    if (mode == ManagerMode.restock || mode == ManagerMode.edit) _loadEditFields();
  }

  // ── Shared ────────────────────────────────────────────────────────────────

  void setNote(String v) => state = state.copyWith(note: v);
  void setLocalImageUrl(String? url) => state = state.copyWith(localImageUrl: url);

  // ── Restock / Edit buckets ────────────────────────────────────────────────

  void setQtyGood(int v) => state = state.copyWith(qtyGood: v);
  void setQtyDamaged(int v) => state = state.copyWith(qtyDamaged: v);
  void setQtyMaintenance(int v) => state = state.copyWith(qtyMaintenance: v);
  void setQtyLost(int v) => state = state.copyWith(qtyLost: v);
  void setStorageLocation(String v) => state = state.copyWith(storageLocation: v);

  void setLocationRegistry(int? id, String locationName) {
    state = state.copyWith(locationRegistryId: id, storageLocation: locationName);
  }

  // ── Handover / Reserve ────────────────────────────────────────────────────

  void setQuantity(int v) => state = state.copyWith(quantity: v);
  void setRecipientName(String v) => state = state.copyWith(recipientName: v);
  void setRecipientOffice(String v) => state = state.copyWith(recipientOffice: v);
  void setRecipientContact(String v) => state = state.copyWith(recipientContact: v);
  void setApprovedBy(String v) => state = state.copyWith(approvedBy: v);
  void setReleasedBy(String v) => state = state.copyWith(releasedBy: v);
  void setExpectedReturnDate(DateTime? d) => state = state.copyWith(expectedReturnDate: d);
  void setPickupScheduledAt(DateTime d) => state = state.copyWith(pickupScheduledAt: d);
  void toggleDateReturn(bool v) => state = state.copyWith(isDateReturn: v);

  // ── Edit metadata ─────────────────────────────────────────────────────────

  void setItemName(String v) => state = state.copyWith(itemName: v);
  void setCategory(String v) => state = state.copyWith(category: v);
  void setSerial(String v) => state = state.copyWith(serial: v);
  void setModel(String v) => state = state.copyWith(model: v);
  void setTargetStock(String raw) {
    state = state.copyWith(targetStock: int.tryParse(raw.trim()) ?? state.targetStock);
  }

  void setMinStock(String raw) {
    state = state.copyWith(minStock: int.tryParse(raw.trim()) ?? state.minStock);
  }

  // ── Async: load edit admin fields ─────────────────────────────────────────

  Future<void> _loadEditFields() async {
    if (state.isEditLoading) return;
    state = state.copyWith(isEditLoading: true, submitError: null);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final fields = await repo.fetchAdminFields(item.id);
      state = state.copyWith(
        isEditLoading: false,
        qtyGood: fields.qtyGood,
        qtyDamaged: fields.qtyDamaged,
        qtyMaintenance: fields.qtyMaintenance,
        qtyLost: fields.qtyLost,
        storageLocation: fields.storageLocation,
        locationRegistryId: fields.locationRegistryId,
      );
    } catch (_) {
      state = state.copyWith(
        isEditLoading: false,
        submitError: 'Failed to load equipment details.',
      );
    }
  }

  // ── Async: submit ─────────────────────────────────────────────────────────

  Future<bool> submit() async {
    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final user = ref.read(currentUserProvider);

      switch (state.mode) {
        case ManagerMode.restock:
          await repo.updateAdminFields(
            itemId: item.id,
            qtyGood: state.qtyGood,
            qtyDamaged: state.qtyDamaged,
            qtyMaintenance: state.qtyMaintenance,
            qtyLost: state.qtyLost,
            storageLocation: state.storageLocation,
            locationRegistryId: state.locationRegistryId,
            forensicNote: state.note,
          );

        case ManagerMode.edit:
          await repo.updateItemMetadata(
            itemId: item.id,
            name: state.itemName,
            category: state.category,
            serialNumber: state.serial.trim().isNotEmpty ? state.serial.trim() : null,
            modelNumber: state.model.trim().isNotEmpty ? state.model.trim() : null,
            targetStock: state.targetStock > 0 ? state.targetStock : null,
            lowStockThreshold: state.minStock > 0 ? state.minStock : null,
          );

        case ManagerMode.handover:
        case ManagerMode.reserve:
          await repo.borrowItem(
            itemId: item.id,
            quantity: state.quantity,
            borrowerName: state.recipientName,
            borrowerContact: state.recipientContact,
            borrowerOrganization: state.recipientOffice,
            approvedBy: state.approvedBy,
            releasedBy: state.releasedBy,
            expectedReturnDate: state.isDateReturn ? state.expectedReturnDate : null,
            pickupScheduledAt:
                state.mode == ManagerMode.reserve ? state.pickupScheduledAt : null,
            purpose: state.note,
            warehouseId: user?.assignedWarehouse,
          );
      }

      ref.read(inventoryNotifierProvider.notifier).refresh();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submitError: 'Action failed: $e');
      return false;
    }
  }
}
