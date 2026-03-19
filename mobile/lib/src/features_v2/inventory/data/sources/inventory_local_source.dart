import 'package:isar/isar.dart';
import '../../../../core/local_storage/isar_service.dart';
import '../../../../features/inventory/models/inventory_model.dart'; // Reuse for Collection Schema
import '../../domain/entities/inventory_item.dart';

class InventoryLocalDataSource {
  final Isar _isar = IsarService.instance;

  /// Watch the inventory for real-time UI updates even while offline
  Stream<List<InventoryItem>> watchItems() {
    return _isar.inventoryCollections
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.map((e) => _mapCollectionToEntity(e)).toList());
  }

  /// Bulk save items from Supabase to Isar
  Future<void> saveAll(List<InventoryItem> items) async {
    await _isar.writeTxn(() async {
      for (final item in items) {
        final existing = await _isar.inventoryCollections
            .filter()
            .originalIdEqualTo(item.id)
            .findFirst();
        
        final collection = _mapEntityToCollection(item);
        if (existing != null) collection.id = existing.id;
        
        await _isar.inventoryCollections.put(collection);
      }
    });
  }

  Future<InventoryItem?> findByQrCode(String qrCode) async {
    final collection = await _isar.inventoryCollections
        .filter()
        .qrCodeEqualTo(qrCode)
        .findFirst();
    
    return collection != null ? _mapCollectionToEntity(collection) : null;
  }

  /// Inner Mapper: Entity <-> Isar Collection
  InventoryItem _mapCollectionToEntity(InventoryCollection col) {
    return InventoryItem(
      id: col.originalId ?? 0,
      name: col.name,
      description: col.description ?? '',
      category: col.category,
      totalStock: col.quantity,
      availableStock: col.available,
      location: col.location ?? '',
      qrCode: col.qrCode,
      status: col.status,
      code: col.code ?? '',
      minStockLevel: col.minStockLevel ?? 10,
      unit: col.unit ?? 'pcs',
      lastUpdated: col.updatedAt,
      imageUrl: col.imageUrl,
    );
  }

  InventoryCollection _mapEntityToCollection(InventoryItem item) {
    return InventoryCollection()
      ..originalId = item.id
      ..name = item.name
      ..description = item.description
      ..category = item.category
      ..quantity = item.totalStock
      ..available = item.availableStock
      ..location = item.location
      ..qrCode = item.qrCode
      ..status = item.status
      ..code = item.code
      ..minStockLevel = item.minStockLevel
      ..unit = item.unit
      ..imageUrl = item.imageUrl
      ..updatedAt = item.lastUpdated;
  }
}
