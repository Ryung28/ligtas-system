import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/loan_item.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
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
  void updateQuantity(int val) => state = state.copyWith(quantity: val);
  void updateBorrowerName(String val) => state = state.copyWith(borrowerName: val);
  void updateBorrowerContact(String val) => state = state.copyWith(borrowerContact: val);
  void updateBorrowerEmail(String val) => state = state.copyWith(borrowerEmail: val);
  void updateBorrowerOrganization(String val) => state = state.copyWith(borrowerOrganization: val);
  void updateNotes(String val) => state = state.copyWith(notes: val);
  void updateReturnDate(DateTime val) => state = state.copyWith(expectedReturnDate: val);
  
  void initiateWithItem(InventoryItem item) {
    state = state.copyWith(selectedItem: item);
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
    if (state.selectedItem == null) return;

    state = state.copyWith(isSubmitting: true, submissionError: null);
    
    try {
      final repo = ref.read(loanRepositoryProvider);
      final item = state.selectedItem!;
      final user = ref.read(currentUserProvider);

      final request = LoanItem(
        id: '', // Supabase generates this
        userId: user?.id, // Explicit UID linkage
        inventoryItemId: item.id.toString(),
        itemName: item.name,
        itemCode: item.code,
        borrowerName: state.borrowerName,
        borrowerContact: state.borrowerContact,
        borrowerEmail: state.borrowerEmail,
        purpose: state.purpose,
        quantityBorrowed: state.quantity,
        borrowDate: DateTime.now(),
        expectedReturnDate: state.expectedReturnDate ?? DateTime.now().add(const Duration(days: 7)),
        notes: state.notes,
        status: LoanStatus.pending,
        borrowedBy: user?.id.toString() ?? 'SYSTEM_USER',
      );

      await repo.createLoan(request);
      
      state = state.copyWith(
        isSubmitting: false, 
        isSuccess: true, 
        currentStep: BorrowStep.success
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: ExceptionHandler.getDisplayMessage(e));
    }
  }
}
