import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_item.freezed.dart';

@freezed
class InventoryItem with _$InventoryItem {
  const InventoryItem._();
  const factory InventoryItem({
    required int id,
    required String name,
    @Default('') String description,
    required String category,
    @Default(0) int totalStock,
    @Default(0) int availableStock,
    @Default('') String location,
    @Default('') String qrCode,
    @Default('Good') String status,
    @Default('') String code,
    @Default(10) int minStockLevel,
    @Default('pcs') String unit,
    String? imageUrl,
    DateTime? lastUpdated,
    @Default(false) bool isPendingSync,
    
    // Hierarchical Location Support
    int? parentId,
    @Default(0) int aggregateTotal,
    @Default(0) int aggregateAvailable,
    int? locationRegistryId, // MASTER IDENTITY ANCHOR
    @Default([]) List<InventoryVariant> variants,
  }) = _InventoryItem;

  // Domain logic method (Example: Check if low stock)
  bool get isLowStock => (aggregateAvailable > 0 ? aggregateAvailable : availableStock) <= minStockLevel;
  
  bool get isOutOffStock => (aggregateAvailable > 0 ? aggregateAvailable : availableStock) <= 0;
  
  bool get hasMultipleLocations => variants.isNotEmpty;
}

@freezed
class InventoryVariant with _$InventoryVariant {
  const factory InventoryVariant({
    required int id,
    required String location,
    required int stockAvailable,
    required int stockTotal,
    required String status,
    int? locationRegistryId, // REGISTRY LINK
  }) = _InventoryVariant;
}
