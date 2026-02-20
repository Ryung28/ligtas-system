import 'package:freezed_annotation/freezed_annotation.dart';
import '../../inventory/models/inventory_model.dart';

part 'borrow_request_state.freezed.dart';

/// Immutable state for the entire borrow request flow.
/// Using Freezed ensures all state transitions are explicit and type-safe.
@freezed
class BorrowRequestState with _$BorrowRequestState {
  const factory BorrowRequestState({
    // ── Step in the multi-step flow ──
    @Default(BorrowStep.form) BorrowStep currentStep,

    // ── Selected inventory item (the item being requested) ──
    InventoryModel? selectedItem,

    // ── Form data (Immutable copies of what the user typed) ──
    @Default('') String borrowerName,
    @Default('') String borrowerContact,
    @Default('') String borrowerEmail,
    @Default('') String borrowerOrganization,
    @Default('') String purpose,
    @Default(1) int quantity,
    @Default('') String notes,

    // ── Borrow logistics ──
    DateTime? expectedReturnDate,

    // ── Async submission tracking ──
    @Default(false) bool isSubmitting,
    String? submissionError,
    @Default(false) bool isSuccess,
  }) = _BorrowRequestState;
}

/// Enum tracking which step of the multi-step borrow request the user is on.
enum BorrowStep {
  form,    // Step 1: Fill in details
  review,  // Step 2: Review before submitting
  success, // Step 3: Success confirmation
}
