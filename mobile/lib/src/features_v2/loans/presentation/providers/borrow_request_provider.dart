import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/loan_item.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/presentation/providers/mission_cart_provider.dart';
import '../../domain/repositories/loan_repository.dart';
import 'loan_provider.dart';
import 'borrow_request_state.dart';
import '../../../../core/errors/app_exceptions.dart';

part 'borrow_request_provider.g.dart';

@riverpod
class BorrowRequestNotifier extends _$BorrowRequestNotifier {
  @override
  BorrowRequestState build() {
    final user = ref.read(currentUserProvider);
    return BorrowRequestState(
      borrowerName: user?.displayName ?? '',
      borrowerContact: user?.phoneNumber ?? '',
      borrowerEmail: user?.email ?? '',
      borrowerOrganization: user?.organization ?? '',
      expectedReturnDate: DateTime.now().add(const Duration(days: 7)),
    );
  }

  void updatePurpose(String val) => state = state.copyWith(purpose: val);
  void updateBorrowerName(String val) => state = state.copyWith(borrowerName: val);
  void updateBorrowerContact(String val) => state = state.copyWith(borrowerContact: val);
  void updateBorrowerEmail(String val) => state = state.copyWith(borrowerEmail: val);
  void updateBorrowerOrganization(String val) => state = state.copyWith(borrowerOrganization: val);
  void updateNotes(String val) => state = state.copyWith(notes: val);
  void updateReturnDate(DateTime val) => state = state.copyWith(expectedReturnDate: val);
  
  void updateItemQuantity(String itemId, int quantity) {
    final newItems = state.cartItems.map((c) {
      if (c.item.id.toString() == itemId) {
        // 🛡️ STOCK GUARD: Clamp quantity to available stock
        final maxStock = c.item.displayStock;
        final clampedQty = quantity.clamp(1, maxStock);
        return c.copyWith(quantity: clampedQty);
      }
      return c;
    }).toList();
    state = state.copyWith(cartItems: newItems);
  }

  void updateItemReturnDate(String itemId, DateTime date) {
    state = state.copyWith(
      itemReturnDates: {...state.itemReturnDates, itemId: date},
    );
  }

  void updateItemPickupDate(String itemId, DateTime date) {
    state = state.copyWith(
      itemPickupDates: {...state.itemPickupDates, itemId: date},
    );
  }

  void updateGlobalReturnDate(DateTime date) {
    final newDates = { for (var entry in state.itemReturnDates.entries) entry.key : date };
    state = state.copyWith(itemReturnDates: newDates);
  }

  void initiateWithCart(List<CartItem> items) {
    final defaultDate = DateTime.now().add(const Duration(days: 7));
    final initialDates = { for (var item in items) item.item.id.toString() : defaultDate };
    state = state.copyWith(
      cartItems: items, 
      itemReturnDates: initialDates, 
      expectedReturnDate: defaultDate
    );
  }

  void proceedToReview() {
    state = state.copyWith(currentStep: BorrowStep.review);
  }

  void goBackToForm() {
    state = state.copyWith(currentStep: BorrowStep.form);
  }

  void reset() {
    ref.invalidateSelf();
  }

  Future<void> submitRequest() async {
    if (state.cartItems.isEmpty) return;

    state = state.copyWith(isSubmitting: true, submissionError: null);
    
    try {
      final repo = ref.read(loanRepositoryProvider);
      final user = ref.read(currentUserProvider);

      final loanRequests = state.cartItems.map((cartItem) {
        return LoanItem(
          id: '',
          userId: user?.id,
          inventoryItemId: cartItem.item.id.toString(),
          itemName: cartItem.item.name,
          itemCode: cartItem.item.code,
          borrowerName: state.borrowerName,
          borrowerContact: state.borrowerContact,
          borrowerEmail: state.borrowerEmail,
          purpose: state.purpose,
          quantityBorrowed: cartItem.quantity,
          borrowDate: DateTime.now(),
          expectedReturnDate: state.itemReturnDates[cartItem.item.id.toString()] ?? state.expectedReturnDate ?? DateTime.now().add(const Duration(days: 7)),
          pickupScheduledAt: state.itemPickupDates[cartItem.item.id.toString()],
          notes: state.notes,
          status: LoanStatus.pending,
          borrowedBy: user?.id.toString() ?? 'SYSTEM_USER',
        );
      }).toList();

      await Future.wait(loanRequests.map((req) => repo.createLoan(req)));
      
      // Clear the global cart on success
      ref.read(missionCartNotifierProvider.notifier).clearCart();
      
      state = state.copyWith(
        isSubmitting: false, 
        isSuccess: true, 
        currentStep: BorrowStep.success
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false, 
        submissionError: ExceptionHandler.getDisplayMessage(e)
      );
    }
  }
}
