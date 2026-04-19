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
    @Default('') String modelNumber,
    @Default(10) int minStockLevel,
    @Default(0) int targetStock,
    @Default('pcs') String unit,
    String? imageUrl,
    DateTime? lastUpdated,
    DateTime? expiryDate,
    @Default(15) int expiryAlertDays,
    @Default(false) bool isPendingSync,
    @Default(true) bool restockAlertEnabled,

    // Health buckets (mirrors web qty_* columns)
    @Default(0) int qtyGood,
    @Default(0) int qtyDamaged,
    @Default(0) int qtyMaintenance,
    @Default(0) int qtyLost,

    // Hierarchical Location Support
    int? parentId,
    @Default(0) int aggregateTotal,
    @Default(0) int aggregateAvailable,
    int? locationRegistryId,
    @Default([]) List<InventoryVariant> variants,
  }) = _InventoryItem;

  /// Exact port of web's isLowStock (web/lib/inventory-utils.ts → isLowStock).
  /// Conditions must match in order:
  ///   1. restock_alert_enabled must be true
  ///   2. status must not be damaged / lost / deleted
  ///   3. available < 5  OR  available <= effectiveThreshold (default 10)
  bool get isLowStock {
    if (!restockAlertEnabled) return false;
    final st = status.toLowerCase();
    if (st == 'damaged' || st == 'lost' || st == 'deleted') return false;
    final available = displayStock;
    final effectiveThreshold = minStockLevel > 0 ? minStockLevel : 10;
    return available < 5 || available <= effectiveThreshold;
  }

  /// True when effective display stock is zero or below.
  bool get isOutOffStock => displayStock <= 0;

  /// Mirrors the Web Inventory "Alerts" tab logic (4-part conditions):
  /// 1. Low Stock (same as isLowStock)
  /// 2. Health Issues — any damaged, maintenance, or lost units
  /// 3. Expiring Soon — consumable within 30 days of expiry
  /// Use this for card-level alert indicators in the inventory list.
  bool get hasAlert {
    if (isLowStock) return true;
    if (qtyDamaged > 0 || qtyMaintenance > 0 || qtyLost > 0) return true;
    if (expiryDate != null) {
      final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
      if (daysLeft <= expiryAlertDays) return true;
    }
    return false;
  }

  /// Alert label shown on the card badge (priority order matches web).
  String get alertLabel {
    if (isOutOffStock) return 'OUT OF STOCK';
    if (expiryDate != null) {
      final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
      if (daysLeft < 0) return 'EXPIRED';
      if (daysLeft <= expiryAlertDays) return 'EXPIRING SOON';
    }
    if (qtyDamaged > 0 || qtyMaintenance > 0 || qtyLost > 0) return 'NEEDS ATTENTION';
    if (isLowStock) return 'LOW STOCK';
    return '';
  }

  /// Prefers aggregateAvailable (cross-location sum) over single-location stock.
  int get displayStock => aggregateAvailable > 0 ? aggregateAvailable : availableStock;

  /// Standardized 'Max' Stock: Prefers targetStock (Web Goal) over current physical totalStock.
  int get displayTotal => targetStock > 0 ? targetStock : (aggregateTotal > 0 ? aggregateTotal : totalStock);

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
    /// Per-site health buckets (from `inventory` row / `active_inventory.variants` JSON).
    @Default(0) int qtyGood,
    @Default(0) int qtyDamaged,
    @Default(0) int qtyMaintenance,
    @Default(0) int qtyLost,
  }) = _InventoryVariant;
}

/// Maps Supabase / Isar JSON variant rows into [InventoryVariant].
InventoryVariant inventoryVariantFromJsonMap(Map<String, dynamic> m) {
  int read(String k) => (m[k] as num?)?.toInt() ?? 0;
  return InventoryVariant(
    id: (m['id'] as num).toInt(),
    location: (m['location'] as String?)?.trim().isNotEmpty == true
        ? (m['location'] as String).trim()
        : 'Unknown',
    stockAvailable: read('stock_available'),
    stockTotal: read('stock_total'),
    status: m['status'] as String? ?? 'Good',
    locationRegistryId: (m['location_registry_id'] as num?)?.toInt(),
    qtyGood: read('qty_good'),
    qtyDamaged: read('qty_damaged'),
    qtyMaintenance: read('qty_maintenance'),
    qtyLost: read('qty_lost'),
  );
}
