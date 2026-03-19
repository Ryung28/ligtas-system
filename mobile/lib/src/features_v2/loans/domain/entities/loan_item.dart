import 'package:freezed_annotation/freezed_annotation.dart';

part 'loan_item.freezed.dart';

enum LoanStatus {
  active,
  overdue,
  returned,
  cancelled,
  pending,
}

@freezed
class LoanItem with _$LoanItem {
  const LoanItem._();
  const factory LoanItem({
    required String id,
    @JsonKey(name: 'user_id') String? userId, // Supports multi-tenant isolation
    required String inventoryItemId,
    required String itemName,
    required String itemCode,
    required String borrowerName,
    required String borrowerContact,
    @Default('') String borrowerEmail,
    required String purpose,
    required int quantityBorrowed,
    required DateTime borrowDate,
    required DateTime expectedReturnDate,
    DateTime? actualReturnDate,
    @Default(LoanStatus.active) LoanStatus status,
    String? notes,
    String? returnNotes,
    required String borrowedBy,
    String? returnedBy,
    @Default(0) int daysOverdue,
    @Default(0) int daysBorrowed,
    @Default(false) bool isPendingSync,
  }) = _LoanItem;

  // Domain logic
  bool get isOverdue => status == LoanStatus.overdue || (actualReturnDate == null && DateTime.now().isAfter(expectedReturnDate));
  
  bool get canBeReturned => status == LoanStatus.active || status == LoanStatus.overdue;
}
