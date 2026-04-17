import 'dart:convert';

import 'package:isar/isar.dart';
import '../../../../core/local_storage/isar_service.dart';
import '../../../../features/inventory/models/inventory_model.dart'; // Reuse for Collection Schema
import '../../domain/entities/inventory_item.dart';

class InventoryLocalDataSource {
  /// 🛡️ THE VAULT: Access through late-initialized Isar instance
  Isar get _isar => IsarService.instance;

  static String? _encodeVariantsForIsar(List<InventoryVariant> variants) {
    if (variants.isEmpty) return null;
    return jsonEncode(
      variants
          .map(
            (e) => <String, dynamic>{
              'id': e.id,
              'location': e.location,
              'location_registry_id': e.locationRegistryId,
              'stock_available': e.stockAvailable,
              'stock_total': e.stockTotal,
              'status': e.status,
              'qty_good': e.qtyGood,
              'qty_damaged': e.qtyDamaged,
              'qty_maintenance': e.qtyMaintenance,
              'qty_lost': e.qtyLost,
            },
          )
          .toList(),
    );
  }

  static List<InventoryVariant> _decodeVariantsFromIsar(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => inventoryVariantFromJsonMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Watch the inventory for real-time UI updates even while offline
  Stream<List<InventoryItem>> watchItems() {
    return _isar.collection<InventoryCollection>()
        .where()
        .sortByOriginalId() // Keep reliable order
        .watch(fireImmediately: true)
        .map((list) => list.map((e) => _mapCollectionToEntity(e)).toList());
  }

  /// 📡 ATOMIC OBSERVATION: Watch a single row for instant UI reactivity
  Stream<InventoryItem?> watchItem(int originalId) {
    // 🛡️ Note: We watch by the domain ID (originalId) which is stored in the collection.
    // Querying by originalId ensures consistency across local instances.
    return _isar.collection<InventoryCollection>()
        .filter()
        .originalIdEqualTo(originalId)
        .watch(fireImmediately: true)
        .map((list) => list.isNotEmpty ? _mapCollectionToEntity(list.first) : null);
  }

  /// 🛡️ METRICS: Direct Isar count
  Future<int> countItems() async {
    return _isar.collection<InventoryCollection>().where().count();
  }

  /// 🚀 THE GOLD STANDARD: Pull specific chunks from disk
  Future<List<InventoryItem>> fetchPagedItems(int offset, int limit, {String? category}) async {
    final List<InventoryCollection> list;
    
    if (category != null && category != 'All') {
      // 🛡️ Path A: Category-specific view (Uses Category Index)
      list = await _isar.collection<InventoryCollection>()
          .filter()
          .categoryEqualTo(category, caseSensitive: false)
          .sortByOriginalId()
          .offset(offset)
          .limit(limit)
          .findAll();
    } else {
      // 🛡️ Path B: Global view (Uses Primary ID Index)
      list = await _isar.collection<InventoryCollection>()
          .where()
          .sortByOriginalId()
          .offset(offset)
          .limit(limit)
          .findAll();
    }
    
    return list.map((e) => _mapCollectionToEntity(e)).toList();
  }

  /// 🛡️ SEARCH BYPASS: Direct disk-level search
  Future<List<InventoryItem>> searchLocal(String query) async {
    final list = await _isar.collection<InventoryCollection>()
        .filter()
        .nameContains(query, caseSensitive: false)
        .or()
        .codeContains(query, caseSensitive: false)
        .or()
        .categoryContains(query, caseSensitive: false)
        .findAll();
    return list.map((e) => _mapCollectionToEntity(e)).toList();
  }

  /// Bulk save items from Supabase to Isar
  Future<void> saveAll(List<InventoryItem> items) async {
    await _isar.writeTxn(() async {
      for (final item in items) {
        // 🛡️ PERFORMANCE: Use 'where' (indexed) instead of 'filter'
        final existing = await _isar.collection<InventoryCollection>()
            .where()
            .originalIdEqualTo(item.id)
            .findFirst();
        
        final collection = _mapEntityToCollection(item);
        if (existing != null) collection.id = existing.id;
        
        await _isar.collection<InventoryCollection>().put(collection);
      }
    });
  }

  Future<InventoryItem?> findByQrCode(String qrCode) async {
    final collection = await _isar.collection<InventoryCollection>()
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
      targetStock: col.targetStock ?? 0,
      unit: col.unit ?? 'pcs',
      lastUpdated: col.updatedAt,
      imageUrl: col.imageUrl,
      restockAlertEnabled: col.restockAlertEnabled,
      qtyGood: col.qtyGood,
      qtyDamaged: col.qtyDamaged,
      qtyMaintenance: col.qtyMaintenance,
      qtyLost: col.qtyLost,
      // Multi-location fields
      aggregateTotal: col.aggregateTotal ?? 0,
      aggregateAvailable: col.aggregateAvailable ?? 0,
      variants: _decodeVariantsFromIsar(col.variantsJson),
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
      ..targetStock = item.targetStock
      ..unit = item.unit
      ..imageUrl = item.imageUrl
      ..updatedAt = item.lastUpdated
      ..restockAlertEnabled = item.restockAlertEnabled
      ..aggregateTotal = item.aggregateTotal
      ..aggregateAvailable = item.aggregateAvailable
      ..qtyGood = item.qtyGood
      ..qtyDamaged = item.qtyDamaged
      ..qtyMaintenance = item.qtyMaintenance
      ..qtyLost = item.qtyLost
      ..variantsJson = _encodeVariantsForIsar(item.variants);
  }
}
