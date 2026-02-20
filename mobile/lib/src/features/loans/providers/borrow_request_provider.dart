import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/borrow_request_state.dart';
import '../models/loan_model.dart';
import '../../inventory/models/inventory_model.dart';
import '../repositories/loan_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/loan_providers.dart';
import '../providers/loan_filter_provider.dart';
import '../../../core/local_storage/isar_service.dart';

/// Senior Dev: Changed back to standard Notifier for Hot-Reload stability.
/// We will handle resets manually in the UI to prevent Step 3 skips.
class BorrowRequestNotifier extends Notifier<BorrowRequestState> {
  late LoanRepository _repository;

  @override
  BorrowRequestState build() {
    _repository = ref.watch(loanRepositoryProvider);
    final user = ref.read(currentUserProvider);
    
    return BorrowRequestState(
      borrowerName: user?.displayName ?? '',
      borrowerContact: user?.phoneNumber ?? '',
      borrowerEmail: user?.email ?? '',
      borrowerOrganization: user?.organization ?? '',
      expectedReturnDate: DateTime.now().add(const Duration(days: 7)),
    );
  }

  // ── Field Update Mutations ──
  void updateBorrowerName(String val) =>
      state = state.copyWith(borrowerName: val);

  void updateBorrowerContact(String val) =>
      state = state.copyWith(borrowerContact: val);

  void updateBorrowerEmail(String val) =>
      state = state.copyWith(borrowerEmail: val);

  void updateBorrowerOrganization(String val) =>
      state = state.copyWith(borrowerOrganization: val);

  void updatePurpose(String val) =>
      state = state.copyWith(purpose: val);

  void updateQuantity(int val) =>
      state = state.copyWith(quantity: val);

  void updateNotes(String val) =>
      state = state.copyWith(notes: val);

  void updateReturnDate(DateTime date) =>
      state = state.copyWith(expectedReturnDate: date);

  // ── Step Navigation ──
  void proceedToReview() {
    state = state.copyWith(
      currentStep: BorrowStep.review,
      submissionError: null,
    );
  }

  void initiateWithItem(InventoryModel item) {
    final user = ref.read(currentUserProvider);
    state = BorrowRequestState(
      selectedItem: item,
      borrowerName: user?.displayName ?? '',
      borrowerContact: user?.phoneNumber ?? '',
      borrowerEmail: user?.email ?? '',
      borrowerOrganization: user?.organization ?? '',
      expectedReturnDate: DateTime.now().add(const Duration(days: 7)),
    );
  }

  void goBackToForm() {
    state = state.copyWith(currentStep: BorrowStep.form);
  }

  void reset() {
    ref.invalidateSelf();
  }

  // ── Core Action: Submit Request ──
  Future<void> submitRequest() async {
    if (state.selectedItem == null) return;

    state = state.copyWith(
      isSubmitting: true,
      submissionError: null,
    );

    try {
      final item = state.selectedItem!;

      final request = CreateLoanRequest(
        inventoryItemId: item.code.isNotEmpty ? item.code : item.id.toString(),
        inventoryId: item.id,
        itemName: item.name,
        itemCode: item.code,
        borrowerName: state.borrowerName,
        borrowerContact: state.borrowerContact,
        borrowerEmail: state.borrowerEmail.isNotEmpty ? state.borrowerEmail : '',
        borrowerOrganization: state.borrowerOrganization,
        purpose: state.purpose,
        quantityBorrowed: state.quantity,
        expectedReturnDate: state.expectedReturnDate!,
        notes: state.notes.isNotEmpty ? state.notes : null,
      );

      // 1. Submit to Supabase
      final newLoan = await _repository.createLoan(request);

      // 2. IMMEDIATE Injection into local Isar
      try {
        await IsarService.saveLoans([newLoan]);
      } catch (e) {
        print('SYSTEM: Local cache sync warning: $e');
      }

      // 3. Update UI State
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        currentStep: BorrowStep.success,
      );

      // 4. Reset filters so the new item (Newest First) appears at the Top
      ref.read(loanFilterProvider.notifier).reset();
      
      // 5. Force background refresh
      ref.invalidate(myBorrowedItemsProvider);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submissionError: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final borrowRequestProvider = NotifierProvider<BorrowRequestNotifier, BorrowRequestState>(
  BorrowRequestNotifier.new,
);
