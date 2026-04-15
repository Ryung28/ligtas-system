import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';
import 'package:mobile/src/features_v2/loans/domain/entities/loan_item.dart' show LoanStatus;
export 'package:mobile/src/features_v2/loans/domain/entities/loan_item.dart' show LoanStatus;

part 'loan_model.freezed.dart';
part 'loan_model.g.dart';

@freezed
class LoanModel with _$LoanModel {
  const factory LoanModel({
    required String id,
    @JsonKey(name: 'inventory_item_id') required String inventoryItemId,
    @JsonKey(name: 'item_name') required String itemName,
    @JsonKey(name: 'item_code') required String itemCode,
    @JsonKey(name: 'borrower_name') required String borrowerName,
    @JsonKey(name: 'borrower_contact') required String borrowerContact,
    @Default('') String borrowerEmail,
    required String purpose,
    @JsonKey(name: 'quantity_borrowed') required int quantityBorrowed,
    @JsonKey(name: 'borrow_date') required DateTime borrowDate,
    @JsonKey(name: 'expected_return_date') required DateTime expectedReturnDate,
    @JsonKey(name: 'actual_return_date') DateTime? actualReturnDate,
    @Default(LoanStatus.active) LoanStatus status,
    String? notes,
    @JsonKey(name: 'return_notes') String? returnNotes,
    @JsonKey(name: 'borrowed_by') required String borrowedBy,
    @JsonKey(name: 'returned_by') String? returnedBy,
    
    // Audit & Accountability fields (Checklist 2.0)
    @JsonKey(name: 'approved_by') String? approvedBy,
    @JsonKey(name: 'approved_at') DateTime? approvedAt,
    @JsonKey(name: 'handed_by') String? handedBy,
    @JsonKey(name: 'handed_at') DateTime? handedAt,
    @JsonKey(name: 'pickup_scheduled_at') DateTime? pickupScheduledAt,
    @JsonKey(name: 'received_by_name') String? receivedByName,
    @JsonKey(name: 'received_by_user_id') String? receivedByUserId,
    @JsonKey(name: 'return_condition') String? returnCondition,
    
    @Default(0) int daysOverdue,
    @Default(0) int daysBorrowed,
    @Default(false) bool isPendingSync,
    String? imageUrl,
  }) = _LoanModel;

  factory LoanModel.fromJson(Map<String, dynamic> json) => _$LoanModelFromJson(json);
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
  
  // Audit & Accountability fields (Checklist 2.0)
  String? approvedBy;
  DateTime? approvedAt;
  String? handedBy;
  DateTime? handedAt;
  DateTime? pickupScheduledAt;
  String? receivedByName;
  String? receivedByUserId;
  String? returnCondition;
  
  late int daysOverdue;
  late int daysBorrowed;
  late bool isPendingSync;
  String? imageUrl;

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
      ..approvedBy = model.approvedBy
      ..approvedAt = model.approvedAt
      ..handedBy = model.handedBy
      ..handedAt = model.handedAt
      ..pickupScheduledAt = model.pickupScheduledAt
      ..receivedByName = model.receivedByName
      ..receivedByUserId = model.receivedByUserId
      ..returnCondition = model.returnCondition
      ..daysOverdue = model.daysOverdue
      ..daysBorrowed = model.daysBorrowed
      ..isPendingSync = model.isPendingSync
      ..imageUrl = model.imageUrl;
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
      approvedBy: approvedBy,
      approvedAt: approvedAt,
      handedBy: handedBy,
      handedAt: handedAt,
      pickupScheduledAt: pickupScheduledAt,
      receivedByName: receivedByName,
      receivedByUserId: receivedByUserId,
      returnCondition: returnCondition,
      daysOverdue: daysOverdue,
      daysBorrowed: daysBorrowed,
      isPendingSync: isPendingSync,
      imageUrl: imageUrl,
    );
  }
}
