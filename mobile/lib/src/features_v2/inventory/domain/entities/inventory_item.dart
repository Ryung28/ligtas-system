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
  }) = _InventoryItem;

  // Domain logic method (Example: Check if low stock)
  bool get isLowStock => availableStock <= minStockLevel;
  
  bool get isOutOffStock => availableStock <= 0;
}
