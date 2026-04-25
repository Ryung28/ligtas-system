import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/inventory_provider.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_mode.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_batch/manager_batch_state.dart';

final managerBatchControllerProvider =
    StateNotifierProvider<ManagerBatchController, ManagerBatchState>(
  (ref) => ManagerBatchController(ref),
);

class ManagerBatchController extends StateNotifier<ManagerBatchState> {
  ManagerBatchController(this.ref) : super(const ManagerBatchState());

  final Ref ref;

  void start(ManagerMode mode) {
    if (mode != ManagerMode.handover && mode != ManagerMode.reserve) return;
    state = ManagerBatchState(activeMode: mode);
  }

  void stop() {
    state = const ManagerBatchState();
  }

  void clearItems() {
    state = state.copyWith(lines: {}, clearSubmitError: true, lastFailures: [], lastSuccessCount: 0);
  }

  bool contains(InventoryItem item) => state.lines.containsKey(item.id);

  void toggleItem(InventoryItem item) {
    if (!state.isActive) return;
    final next = Map<int, ManagerBatchLine>.from(state.lines);
    if (next.containsKey(item.id)) {
      next.remove(item.id);
    } else {
      if (item.availableStock <= 0) return;
      next[item.id] = ManagerBatchLine(item: item, quantity: 1);
    }
    state = state.copyWith(lines: next, clearSubmitError: true, lastFailures: []);
  }

  void increment(InventoryItem item) {
    final existing = state.lines[item.id];
    if (existing == null) return;
    if (existing.quantity >= item.availableStock) return;
    final next = Map<int, ManagerBatchLine>.from(state.lines);
    next[item.id] = existing.copyWith(quantity: existing.quantity + 1);
    state = state.copyWith(lines: next, clearSubmitError: true);
  }

  void decrement(InventoryItem item) {
    final existing = state.lines[item.id];
    if (existing == null) return;
    final next = Map<int, ManagerBatchLine>.from(state.lines);
    if (existing.quantity <= 1) {
      next.remove(item.id);
    } else {
      next[item.id] = existing.copyWith(quantity: existing.quantity - 1);
    }
    state = state.copyWith(lines: next, clearSubmitError: true);
  }

  void updateQuantity(InventoryItem item, int quantity) {
    final next = Map<int, ManagerBatchLine>.from(state.lines);
    if (quantity <= 0) {
      next.remove(item.id);
    } else {
      final capped = quantity.clamp(0, item.availableStock);
      if (capped == 0) {
        next.remove(item.id);
      } else {
        next[item.id] = ManagerBatchLine(item: item, quantity: capped);
      }
    }
    state = state.copyWith(lines: next, clearSubmitError: true);
  }

  Future<bool> submit({
    required String recipientName,
    required String recipientOffice,
    required String recipientContact,
    required String approvedBy,
    required String releasedBy,
    required String purpose,
    DateTime? expectedReturnDate,
    DateTime? pickupScheduledAt,
  }) async {
    if (!state.isActive || state.lines.isEmpty) return false;
    if (recipientName.trim().isEmpty) {
      state = state.copyWith(submitError: 'Recipient name is required.');
      return false;
    }
    if (approvedBy.trim().isEmpty) {
      state = state.copyWith(submitError: 'Approved by is required.');
      return false;
    }
    if (state.isReserveMode && pickupScheduledAt == null) {
      state = state.copyWith(submitError: 'Pickup schedule is required for reserve.');
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearSubmitError: true,
      lastFailures: [],
      lastSuccessCount: 0,
    );

    final repo = ref.read(inventoryRepositoryProvider);
    final user = ref.read(currentUserProvider);
    final failures = <ManagerBatchFailure>[];
    var successCount = 0;

    for (final line in state.lines.values) {
      try {
        await repo.borrowItem(
          itemId: line.item.id,
          quantity: line.quantity,
          borrowerName: recipientName.trim(),
          borrowerContact: recipientContact.trim(),
          borrowerOrganization: recipientOffice.trim(),
          approvedBy: approvedBy.trim(),
          releasedBy: releasedBy.trim().isEmpty ? (user?.displayName ?? 'Authorized Staff') : releasedBy.trim(),
          expectedReturnDate: expectedReturnDate,
          pickupScheduledAt: state.isReserveMode ? pickupScheduledAt : null,
          purpose: purpose.trim(),
          warehouseId: user?.assignedWarehouse,
        );
        successCount += 1;
      } catch (e) {
        failures.add(ManagerBatchFailure(itemName: line.item.name, error: e.toString()));
      }
    }

    ref.read(inventoryNotifierProvider.notifier).refresh();

    if (failures.isEmpty) {
      stop();
    } else {
      state = state.copyWith(
        isSubmitting: false,
        lastFailures: failures,
        lastSuccessCount: successCount,
        submitError: 'Some items failed. Review and retry.',
      );
    }

    return failures.isEmpty;
  }
}
