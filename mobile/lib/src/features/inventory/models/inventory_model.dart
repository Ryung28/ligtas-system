import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';

part 'inventory_model.freezed.dart';
part 'inventory_model.g.dart';

@freezed
class InventoryModel with _$InventoryModel {
  const factory InventoryModel({
    required int id,
    @JsonKey(name: 'item_name') required String name,
    @Default('') String description,
    required String category,
    @JsonKey(name: 'stock_total') required int quantity,
    @JsonKey(name: 'stock_available') required int available,
    @Default('') String location,
    @Default('') String qrCode,
    @Default('Good') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @Default('') String code,
    @Default(10) int minStockLevel,
    @Default('pcs') String unit,
    String? supplier,
    String? supplierContact,
    String? notes,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _InventoryModel;

  factory InventoryModel.fromJson(Map<String, dynamic> json) => _$InventoryModelFromJson(json);
}

/// This is the clean class Isar uses to save data.
/// No Freezed "magic" here, so no build errors!
@collection
class InventoryCollection {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  int? originalId;
  
  late String name;
  String? description;
  late String category;
  late int quantity;
  late int available;
  String? location;
  late String qrCode;
  late String status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? code;
  int? minStockLevel;
  String? unit;
  String? supplier;
  String? supplierContact;
  String? notes;
  String? imageUrl;

  // Convert from Model to Entity
  static InventoryCollection fromModel(InventoryModel model) {
    return InventoryCollection()
      ..originalId = model.id
      ..name = model.name
      ..description = model.description
      ..category = model.category
      ..quantity = model.quantity
      ..available = model.available
      ..location = model.location
      ..qrCode = model.qrCode
      ..status = model.status
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt
      ..code = model.code
      ..minStockLevel = model.minStockLevel
      ..unit = model.unit
      ..supplier = model.supplier
      ..supplierContact = model.supplierContact
      ..notes = model.notes
      ..imageUrl = model.imageUrl;
  }

  // Convert from Entity back to Model
  InventoryModel toModel() {
    return InventoryModel(
      id: originalId ?? 0,
      name: name,
      description: description ?? '',
      category: category,
      quantity: quantity,
      available: available,
      location: location ?? '',
      qrCode: qrCode,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      code: code ?? '',
      minStockLevel: minStockLevel ?? 10,
      unit: unit ?? 'pcs',
      supplier: supplier,
      supplierContact: supplierContact,
      notes: notes,
      imageUrl: imageUrl,
    );
  }
}