import 'package:freezed_annotation/freezed_annotation.dart';

part 'loan_item.freezed.dart';

enum LoanStatus {
  active,
  overdue,
  returned,
  cancelled,
  pending,
  staged,
  reserved,
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
    @Default('') String borrowerOrganization,
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
    
    // Audit & Accountability fields (Checklist 2.0)
    @JsonKey(name: 'approved_by') String? approvedBy,
    @JsonKey(name: 'approved_at') DateTime? approvedAt,
    @JsonKey(name: 'handed_by') String? handedBy,
    @JsonKey(name: 'handed_at') DateTime? handedAt,
    @JsonKey(name: 'received_by_name') String? receivedByName,
    @JsonKey(name: 'received_by_user_id') String? receivedByUserId,
    @JsonKey(name: 'return_condition') String? returnCondition,
    @JsonKey(name: 'pickup_scheduled_at') DateTime? pickupScheduledAt,
    
    @Default(0) int daysOverdue,
    @Default(0) int daysBorrowed,
    @Default(false) bool isPendingSync,
    String? imageUrl, // Field-Ready Visual Metadata
  }) = _LoanItem;

  // Domain logic
  bool get isOverdue => status == LoanStatus.overdue || (actualReturnDate == null && DateTime.now().isAfter(expectedReturnDate));
  
  bool get canBeReturned => status == LoanStatus.active || status == LoanStatus.overdue;
}
