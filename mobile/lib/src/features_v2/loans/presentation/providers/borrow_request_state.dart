import 'package:freezed_annotation/freezed_annotation.dart'; // [Trigger: Finalizing Schema]
import '../../../../features_v2/inventory/domain/entities/inventory_item.dart';
import '../../../../features_v2/inventory/presentation/providers/mission_cart_provider.dart';

part 'borrow_request_state.freezed.dart';

@freezed
class BorrowRequestState with _$BorrowRequestState {
  const factory BorrowRequestState({
    @Default(BorrowStep.form) BorrowStep currentStep,
    @Default([]) List<CartItem> cartItems,
    @Default('') String borrowerName,
    @Default('') String borrowerContact,
    @Default('') String borrowerEmail,
    @Default('') String borrowerOrganization,
    @Default('') String purpose,
    @Default('') String notes,
    DateTime? expectedReturnDate,
    @Default({}) Map<String, DateTime> itemReturnDates,
    @Default({}) Map<String, DateTime> itemPickupDates,
    @Default(false) bool isSubmitting,
    String? submissionError,
    @Default(false) bool isSuccess,
  }) = _BorrowRequestState;
}

enum BorrowStep { form, review, success }
