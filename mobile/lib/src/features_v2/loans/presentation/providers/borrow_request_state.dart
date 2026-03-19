import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../features_v2/inventory/domain/entities/inventory_item.dart';

part 'borrow_request_state.freezed.dart';

@freezed
class BorrowRequestState with _$BorrowRequestState {
  const factory BorrowRequestState({
    @Default(BorrowStep.form) BorrowStep currentStep,
    InventoryItem? selectedItem,
    @Default('') String borrowerName,
    @Default('') String borrowerContact,
    @Default('') String borrowerEmail,
    @Default('') String borrowerOrganization,
    @Default('') String purpose,
    @Default(1) int quantity,
    @Default('') String notes,
    DateTime? expectedReturnDate,
    @Default(false) bool isSubmitting,
    String? submissionError,
    @Default(false) bool isSuccess,
  }) = _BorrowRequestState;
}

enum BorrowStep { form, review, success }
