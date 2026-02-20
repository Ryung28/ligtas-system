import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    int? id,
    required int inventoryId,
    required String borrowerName,
    required String borrowerContact,
    required String purpose,
    required int quantity,
    required DateTime borrowDate,
    DateTime? returnDate,
    required String status, // 'borrowed', 'returned', 'overdue'
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isPendingSync,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);
}

@collection
class TransactionCollection {
  Id id = Isar.autoIncrement;

  @Index()
  int? originalId;

  late int inventoryId;
  late String borrowerName;
  late String borrowerContact;
  late String purpose;
  late int quantity;
  late DateTime borrowDate;
  DateTime? returnDate;
  late String status;
  late DateTime createdAt;
  DateTime? updatedAt;
  late bool isPendingSync;

  static TransactionCollection fromModel(TransactionModel model) {
    return TransactionCollection()
      ..originalId = model.id
      ..inventoryId = model.inventoryId
      ..borrowerName = model.borrowerName
      ..borrowerContact = model.borrowerContact
      ..purpose = model.purpose
      ..quantity = model.quantity
      ..borrowDate = model.borrowDate
      ..returnDate = model.returnDate
      ..status = model.status
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt
      ..isPendingSync = model.isPendingSync;
  }

  TransactionModel toModel() {
    return TransactionModel(
      id: originalId,
      inventoryId: inventoryId,
      borrowerName: borrowerName,
      borrowerContact: borrowerContact,
      purpose: purpose,
      quantity: quantity,
      borrowDate: borrowDate,
      returnDate: returnDate,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPendingSync: isPendingSync,
    );
  }
}