import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../features/inventory/models/inventory_model.dart'; // Reuse for DTO/Model
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../sources/inventory_local_source.dart';
import '../../../../core/errors/app_exceptions.dart';

/// Senior Architect Choice: The Orchestrator
/// This repository now manages both Remote (Supabase) and Local (Isar)
/// ensuring the user always sees data, even with zero network.
class SupabaseInventoryRepository implements IInventoryRepository {
  final SupabaseClient _client;
  final InventoryLocalDataSource _local;

  SupabaseInventoryRepository(this._client, this._local);

  @override
  Future<List<InventoryItem>> fetchAll() async {
    try {
      // 🛡️ STEEL CAGE: Querying the active_inventory view instead of raw table
      final response = await _client
          .from('active_inventory')
          .select('*')
          .order('item_name', ascending: true);
      
      final List<dynamic> data = response;
      
      final items = data.map((json) {
        final model = InventoryModel.fromJson(json);
        return _mapModelToEntity(model);
      }).toList();

      // 1. Parallel Sync
       _local.saveAll(items);

      return items;
    } catch (e) {
      // Resilience: Log but return empty to favor watching Local Stream
      debugPrint('Fetch Error: ${ExceptionHandler.getDisplayMessage(e)}');
      return []; 
    }
  }

  /// Watch local storage for real-time reactivity
  Stream<List<InventoryItem>> watchItems() => _local.watchItems();

  @override
  Future<InventoryItem?> findByQrCode(String code) async {
    try {
      // 🛡️ STEEL CAGE: Ensuring deleted items aren't found via scan
      final response = await _client
          .from('active_inventory')
          .select('*')
          .eq('qr_code', code)
          .maybeSingle();

      if (response != null) {
        final model = InventoryModel.fromJson(response);
        final item = _mapModelToEntity(model);
        _local.saveAll([item]);
        return item;
      }
    } catch (e) {
      debugPrint('QR Lookup Error: ${ExceptionHandler.getDisplayMessage(e)}');
    }
    return _local.findByQrCode(code);
  }

  @override
  Future<void> syncLocalWithRemote() async {
    // Basic Sync: Just re-fetch everything
    await fetchAll();
  }

  @override
  Stream<void> watchRemote() {
    return _client
        .from('active_inventory')
        .stream(primaryKey: ['id'])
        .map((data) {
          final items = data.map((json) {
            final model = InventoryModel.fromJson(json);
            return _mapModelToEntity(model);
          }).toList();
          _local.saveAll(items);
        });
  }

  @override
  Future<void> archiveItem(String id) async {
    try {
      debugPrint('[LIGTAS-Security] 🛡️ Soft-Deleting Item: $id');
      
      // 🛡️ Logic Redirection: UPDATE instead of DELETE
      await _client
          .from('inventory')
          .update({
            'deleted_at': DateTime.now().toUtc().toIso8601String(),
            'status': 'archived'
          })
          .eq('id', id);

      // Local update
      final items = await _local.watchItems().first;
      final updatedItems = items.where((i) => i.id.toString() != id).toList();
      _local.saveAll(updatedItems);
      
    } catch (e) {
      debugPrint('[LIGTAS-Security] 🛑 Archive failed: $e');
      rethrow;
    }
  }

  /// The Buffer Zone: Mapping DTO -> Entity
  InventoryItem _mapModelToEntity(InventoryModel model) {
    return InventoryItem(
      id: model.id,
      name: model.name,
      description: model.description,
      category: model.category,
      totalStock: model.quantity,
      availableStock: model.available,
      location: model.location,
      qrCode: model.qrCode,
      status: model.status,
      code: model.code,
      minStockLevel: model.minStockLevel,
      unit: model.unit,
      imageUrl: model.imageUrl,
      lastUpdated: model.updatedAt,
    );
  }
}
