import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/dispatch_session.dart';
import '../repository/dispatch_repository.dart';
import '../../auth/presentation/providers/auth_providers.dart';

part 'dispatch_controller.g.dart';

@Riverpod(keepAlive: true)
class FastDispatchController extends _$FastDispatchController {
  @override
  FutureOr<DispatchState> build() {
    return const DispatchState();
  }

  /// 👥 Set borrower from Scan or Manual entry
  void setBorrower(BorrowerInfo borrower) {
    final currentState = state.value ?? const DispatchState();
    state = AsyncData(currentState.copyWith(
      borrower: borrower,
      error: null,
    ));
  }

  /// 🧾 Keep borrower state in sync with manual form input
  void updateBorrowerDraft({
    String? name,
    String? contact,
    String? office,
  }) {
    final currentState = state.value ?? const DispatchState();
    final existing = currentState.borrower;
    final nextName = name ?? existing?.name ?? '';
    final nextContact = contact ?? existing?.contact ?? '';
    final nextOffice = office ?? existing?.office ?? '';

    state = AsyncData(currentState.copyWith(
      borrower: BorrowerInfo(
        id: existing?.id ?? 'manual-${DateTime.now().millisecondsSinceEpoch}',
        name: nextName,
        contact: nextContact,
        office: nextOffice,
        isDraft: true,
      ),
      error: null,
    ));
  }

  /// ✍️ Update Approval
  void updateApprovedBy(String value) {
    final currentState = state.value ?? const DispatchState();
    state = AsyncData(currentState.copyWith(approvedBy: value));
  }

  /// 🛠️ Select equipment for dispatch
  void selectItem(int id, String name, {String? imageUrl}) {
    final currentState = state.value ?? const DispatchState();
    state = AsyncData(currentState.copyWith(
      selectedItem: DispatchItem(inventoryId: id, itemName: name, imageUrl: imageUrl),
    ));
  }

  /// 🔢 Update selected quantity for current equipment
  void updateItemQuantity(int quantity) {
    final currentState = state.value ?? const DispatchState();
    final item = currentState.selectedItem;
    if (item == null) return;

    state = AsyncData(currentState.copyWith(
      selectedItem: item.copyWith(quantity: quantity.clamp(1, 999)),
      error: null,
    ));
  }

  /// ❌ Clear selection
  void clearSelection() {
    final currentState = state.value ?? const DispatchState();
    state = AsyncData(currentState.copyWith(selectedItem: null));
  }

  /// 📤 Finalize Transaction
  Future<void> submit() async {
    final currentState = state.value;
    if (currentState == null || currentState.selectedItem == null) {
      state = AsyncData((currentState ?? const DispatchState()).copyWith(error: 'No item selected'));
      return;
    }
    final borrower = currentState.borrower;
    final hasValidBorrower = borrower != null &&
        borrower.name.trim().isNotEmpty &&
        borrower.contact.trim().isNotEmpty &&
        (borrower.office?.trim().isNotEmpty ?? false);
    if (!hasValidBorrower) {
      state = AsyncData(currentState.copyWith(error: 'Complete borrower name, contact, and office'));
      return;
    }

    state = const AsyncLoading();
    
    try {
      final repo = DispatchRepository(Supabase.instance.client);
      final user = ref.read(currentUserProvider);
      final releasedBy = user?.fullName ?? user?.email ?? 'Unknown Manager';

      await repo.submitDispatch(
        borrower: borrower,
        item: currentState.selectedItem!,
        approvedBy: currentState.approvedBy ?? '',
        releasedBy: releasedBy,
        releasedByUserId: user?.id,
      );

      // Reset on success
      state = const AsyncData(DispatchState());
    } catch (e) {
      state = AsyncData(currentState.copyWith(
        error: 'Dispatch Failed: ${e.toString()}',
      ));
    }
  }
}
