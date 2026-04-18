class InventoryAdminFields {
  final int qtyGood;
  final int qtyDamaged;
  final int qtyMaintenance;
  final int qtyLost;

  final int stockTotal;
  final int stockAvailable;

  final String storageLocation;
  final int? locationRegistryId;
  final int targetStock;

  const InventoryAdminFields({
    required this.qtyGood,
    required this.qtyDamaged,
    required this.qtyMaintenance,
    required this.qtyLost,
    required this.stockTotal,
    required this.stockAvailable,
    required this.storageLocation,
    required this.locationRegistryId,
    required this.targetStock,
  });
}

