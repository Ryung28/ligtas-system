import 'dart:convert';

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
    @JsonKey(name: 'stock_total') @Default(0) int quantity,
    @JsonKey(name: 'stock_available') @Default(0) int available,
    @Default('') String location,
    @Default('') String qrCode,
    @Default('Good') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @Default('') String code,
    @JsonKey(name: 'model_number') @Default('') String modelNumber,
    @JsonKey(name: 'low_stock_threshold') @Default(10) int minStockLevel,
    @JsonKey(name: 'target_stock') @Default(0) int targetStock,
    @Default('pcs') String unit,
    @Default('') String supplier,
    @Default('') String supplierContact,
    @Default('') String notes,
    @JsonKey(name: 'image_url') @Default('') String imageUrl,
    @JsonKey(name: 'restock_alert_enabled') @Default(true) bool restockAlertEnabled,
    
    // Multi-location fields
    @JsonKey(name: 'aggregate_total') @Default(0) int aggregateTotal,
    @JsonKey(name: 'aggregate_available') @Default(0) int aggregateAvailable,
    @JsonKey(name: 'primary_location') String? primaryLocation,
    @JsonKey(name: 'primary_stock_available') @Default(0) int primaryAvailable,
    @JsonKey(name: 'location_registry_id') int? locationRegistryId, // MASTER IDENTITY ANCHOR
    @Default([]) List<Map<String, dynamic>> variants,
    @JsonKey(name: 'qty_good') @Default(0) int qtyGood,
    @JsonKey(name: 'qty_damaged') @Default(0) int qtyDamaged,
    @JsonKey(name: 'qty_maintenance') @Default(0) int qtyMaintenance,
    @JsonKey(name: 'qty_lost') @Default(0) int qtyLost,
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
  
  @Index()
  late String category;
  late int quantity;
  late int available;
  String? location;
  late String qrCode;
  late String status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? code;
  String? modelNumber;
  int? targetStock;
  int? minStockLevel;
  String? unit;
  String? supplier;
  String? supplierContact;
  String? notes;
  String? imageUrl;
  bool restockAlertEnabled = true;
  
  int? aggregateTotal;
  int? aggregateAvailable;
  int? locationRegistryId;

  int qtyGood = 0;
  int qtyDamaged = 0;
  int qtyMaintenance = 0;
  int qtyLost = 0;
  String? variantsJson;

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
      ..modelNumber = model.modelNumber
      ..targetStock = model.targetStock
      ..minStockLevel = model.minStockLevel
      ..unit = model.unit
      ..supplier = model.supplier
      ..supplierContact = model.supplierContact
      ..notes = model.notes
      ..imageUrl = model.imageUrl
      ..restockAlertEnabled = model.restockAlertEnabled
      ..aggregateTotal = model.aggregateTotal
      ..aggregateAvailable = model.aggregateAvailable
      ..locationRegistryId = model.locationRegistryId
      ..qtyGood = model.qtyGood
      ..qtyDamaged = model.qtyDamaged
      ..qtyMaintenance = model.qtyMaintenance
      ..qtyLost = model.qtyLost
      ..variantsJson = _encodeVariantsList(model.variants);
  }

  static String? _encodeVariantsList(List<Map<String, dynamic>> variants) {
    if (variants.isEmpty) return null;
    try {
      return jsonEncode(variants);
    } catch (_) {
      return null;
    }
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
      modelNumber: modelNumber ?? '',
      targetStock: targetStock ?? 0,
      minStockLevel: minStockLevel ?? 10,
      unit: unit ?? 'pcs',
      supplier: supplier ?? '',
      supplierContact: supplierContact ?? '',
      notes: notes ?? '',
      imageUrl: imageUrl ?? '',
      restockAlertEnabled: restockAlertEnabled,
      aggregateTotal: aggregateTotal ?? 0,
      aggregateAvailable: aggregateAvailable ?? 0,
      locationRegistryId: locationRegistryId,
      qtyGood: qtyGood,
      qtyDamaged: qtyDamaged,
      qtyMaintenance: qtyMaintenance,
      qtyLost: qtyLost,
      variants: _decodeVariantsList(variantsJson),
    );
  }

  static List<Map<String, dynamic>> _decodeVariantsList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }
}
