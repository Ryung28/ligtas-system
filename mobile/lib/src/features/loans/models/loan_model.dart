import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../core/errors/app_exceptions.dart';

part 'loan_model.freezed.dart';
part 'loan_model.g.dart';

/// Loan status enumeration
enum LoanStatus {
  active,
  overdue,
  returned,
  cancelled,
  pending,
}

@freezed
class LoanModel with _$LoanModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory LoanModel({
    required String id,
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
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isPendingSync,
    @Default(0) int daysOverdue,
    @Default(0) int daysBorrowed,
  }) = _LoanModel;

  factory LoanModel.fromJson(Map<String, dynamic> json) => _$LoanModelFromJson(json);

  factory LoanModel.fromSupabase(Map<String, dynamic> data) {
    // 1. Convert Status (DB 'borrowed'/'Pending' -> Enum 'active'/'pending')
    final rawStatus = (data['status'] as String? ?? 'active').toLowerCase();
    
    LoanStatus finalStatus;
    if (rawStatus == 'borrowed') {
      finalStatus = LoanStatus.active;
    } else if (rawStatus == 'overdue') {
      finalStatus = LoanStatus.overdue;
    } else if (rawStatus == 'returned') {
      finalStatus = LoanStatus.returned;
    } else if (rawStatus == 'cancelled') {
      finalStatus = LoanStatus.cancelled;
    } else if (rawStatus == 'pending') {
      finalStatus = LoanStatus.pending;
    } else {
      finalStatus = LoanStatus.active; // Fallback
    }

    // Senior Dev: Use server time (created_at) as fallback, NOT phone time
    final borrowDateStr = data['borrow_date'] as String? ?? data['created_at'] as String? ?? DateTime.now().toIso8601String();
    final expectedDateStr = data['expected_return_date'] as String? ?? DateTime.now().add(const Duration(days: 7)).toIso8601String();

    // Senior Dev: Always convert to local time for consistent UI comparison and timeago calculations
    final borrowDate = DateTime.parse(borrowDateStr).toLocal();
    final expectedReturnDate = DateTime.parse(expectedDateStr).toLocal();
    final now = DateTime.now();
    
    final dbDaysBorrowed = now.difference(borrowDate).inDays;
    final dbDaysOverdue = expectedReturnDate.isBefore(now) 
        ? now.difference(expectedReturnDate).inDays 
        : 0;

    // 2. Manual Mapping (Senior Dev: Defensive Coding)
    final itemName = data['item_name'] as String? ?? 
                    data['inventory_item_name'] as String? ?? 
                    '';
                    
    final itemCode = data['item_code'] as String? ?? 
                    data['inventory_item_id'] as String? ?? 
                    data['inventory_id']?.toString() ?? 
                    '';

    return LoanModel(
      id: data['id'].toString(),
      inventoryItemId: (data['inventory_item_id'] ?? data['inventory_id'] ?? '').toString(),
      itemName: itemName,
      itemCode: itemCode,
      borrowerName: data['borrower_name'] as String? ?? 'Unknown',
      borrowerContact: data['borrower_contact'] as String? ?? '',
      borrowerEmail: data['borrower_email'] as String? ?? '',
      purpose: data['purpose'] as String? ?? '',
      quantityBorrowed: (data['quantity_borrowed'] ?? data['quantity'] ?? 1) as int,
      borrowDate: borrowDate,
      expectedReturnDate: expectedReturnDate,
      actualReturnDate: data['actual_return_date'] != null ? DateTime.parse(data['actual_return_date'] as String).toLocal() : null,
      status: finalStatus,
      notes: data['notes'] as String?,
      returnNotes: data['return_notes'] as String?,
      borrowedBy: (data['borrowed_by'] ?? data['borrower_user_id'] ?? '').toString(),
      returnedBy: data['returned_by']?.toString(),
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at'] as String).toLocal() : DateTime.now(),
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String).toLocal() : null,
      daysBorrowed: dbDaysBorrowed,
      daysOverdue: dbDaysOverdue,
    );
  }
}

@collection
class LoanCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String originalId;

  late String inventoryItemId;
  late String itemName;
  late String itemCode;
  late String borrowerName;
  late String borrowerContact;
  String? borrowerEmail;
  late String purpose;
  late int quantityBorrowed;
  late DateTime borrowDate;
  late DateTime expectedReturnDate;
  DateTime? actualReturnDate;
  
  @enumerated
  late LoanStatus status;
  
  String? notes;
  String? returnNotes;
  late String borrowedBy;
  String? returnedBy;
  late DateTime createdAt;
  DateTime? updatedAt;
  late bool isPendingSync;
  late int daysOverdue;
  late int daysBorrowed;

  static LoanCollection fromModel(LoanModel model) {
    return LoanCollection()
      ..originalId = model.id
      ..inventoryItemId = model.inventoryItemId
      ..itemName = model.itemName
      ..itemCode = model.itemCode
      ..borrowerName = model.borrowerName
      ..borrowerContact = model.borrowerContact
      ..borrowerEmail = model.borrowerEmail
      ..purpose = model.purpose
      ..quantityBorrowed = model.quantityBorrowed
      ..borrowDate = model.borrowDate
      ..expectedReturnDate = model.expectedReturnDate
      ..actualReturnDate = model.actualReturnDate
      ..status = model.status
      ..notes = model.notes
      ..returnNotes = model.returnNotes
      ..borrowedBy = model.borrowedBy
      ..returnedBy = model.returnedBy
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt
      ..isPendingSync = model.isPendingSync
      ..daysOverdue = model.daysOverdue
      ..daysBorrowed = model.daysBorrowed;
  }

  LoanModel toModel() {
    return LoanModel(
      id: originalId,
      inventoryItemId: inventoryItemId,
      itemName: itemName,
      itemCode: itemCode,
      borrowerName: borrowerName,
      borrowerContact: borrowerContact,
      borrowerEmail: borrowerEmail ?? '',
      purpose: purpose,
      quantityBorrowed: quantityBorrowed,
      borrowDate: borrowDate,
      expectedReturnDate: expectedReturnDate,
      actualReturnDate: actualReturnDate,
      status: status,
      notes: notes,
      returnNotes: returnNotes,
      borrowedBy: borrowedBy,
      returnedBy: returnedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPendingSync: isPendingSync,
      daysOverdue: daysOverdue,
      daysBorrowed: daysBorrowed,
    );
  }
}

@freezed
class CreateLoanRequest with _$CreateLoanRequest {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CreateLoanRequest({
    required String inventoryItemId,
    int? inventoryId,
    required String itemName,
    String? itemCode,
    required String borrowerName,
    required String borrowerContact,
    required String borrowerEmail,
    required String borrowerOrganization,
    required String purpose,
    required int quantityBorrowed,
    required DateTime expectedReturnDate,
    String? notes,
  }) = _CreateLoanRequest;

  factory CreateLoanRequest.fromJson(Map<String, dynamic> json) => _$CreateLoanRequestFromJson(json);
}

@freezed
class ReturnLoanRequest with _$ReturnLoanRequest {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ReturnLoanRequest({
    required String loanId,
    required int quantityReturned,
    String? returnNotes,
    String? condition,
  }) = _ReturnLoanRequest;

  factory ReturnLoanRequest.fromJson(Map<String, dynamic> json) => _$ReturnLoanRequestFromJson(json);
}

@freezed
class LoanStatistics with _$LoanStatistics {
  const factory LoanStatistics({
    @Default(0) int totalActiveLoans,
    @Default(0) int totalOverdueLoans,
    @Default(0) int totalReturnedToday,
    @Default(0) int totalItemsBorrowed,
    @Default(0.0) double averageLoanDuration,
  }) = _LoanStatistics;

  factory LoanStatistics.fromJson(Map<String, dynamic> json) => _$LoanStatisticsFromJson(json);
}