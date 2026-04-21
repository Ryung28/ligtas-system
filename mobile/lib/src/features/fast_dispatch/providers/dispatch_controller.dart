import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/dispatch_session.dart';
import '../repository/dispatch_repository.dart';
import '../../auth/providers/auth_provider.dart';

part 'dispatch_controller.g.dart';

@riverpod
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

  /// 🛠️ Add equipment to cart
  void addItem(int id, String name) {
    final currentState = state.value ?? const DispatchState();
    
    // Check if exists, increase qty
    final existingIndex = currentState.items.indexWhere((i) => i.inventoryId == id);
    final newItems = List<DispatchItem>.from(currentState.items);
    
    if (existingIndex >= 0) {
      newItems[existingIndex] = newItems[existingIndex].copyWith(
        quantity: newItems[existingIndex].quantity + 1,
      );
    } else {
      newItems.add(DispatchItem(inventoryId: id, itemName: name));
    }

    state = AsyncData(currentState.copyWith(items: newItems));
  }

  /// ❌ Remove item from cart
  void removeItem(int id) {
    final currentState = state.value ?? const DispatchState();
    state = AsyncData(currentState.copyWith(
      items: currentState.items.where((i) => i.inventoryId != id).toList(),
    ));
  }

  /// 📤 Finalize Transaction
  Future<void> submit(String approvedBy) async {
    final currentState = state.value;
    if (currentState == null || currentState.borrower == null || currentState.items.isEmpty) {
      state = AsyncData(currentState!.copyWith(error: 'Incomplete dispatch data'));
      return;
    }

    state = const AsyncLoading();
    
    try {
      final repo = DispatchRepository(Supabase.instance.client);
      final user = ref.read(authStateProvider).value?.user;
      final releasedBy = user?.email ?? 'Unknown Manager';

      await repo.submitDispatch(
        borrower: currentState.borrower!,
        items: currentState.items,
        approvedBy: approvedBy,
        releasedBy: releasedBy,
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
