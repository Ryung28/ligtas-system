import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../models/inventory_item.dart';
import '../../../core/di/app_providers.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/local_storage/isar_service.dart';
import 'dart:async';

// Repository interface for inventory operations
abstract class InventoryRepository {
  Future<List<InventoryModel>> getAllItems();
  Stream<List<InventoryModel>> watchInventory();
  Future<InventoryModel> getItemById(int id);
  Future<List<InventoryModel>> getItemsByCategory(String category);
  Future<List<InventoryModel>> searchItems(String query);
}

// Supabase implementation for inventory operations
class SupabaseInventoryRepository implements InventoryRepository {
  final SupabaseClient _client;

  SupabaseInventoryRepository(this._client);

  @override
  Future<List<InventoryModel>> getAllItems() async {
    try {
      final response = await _client
          .from('inventory')
          .select('id, item_name, category, stock_total, stock_available, status, created_at, updated_at, image_url')
          .order('created_at', ascending: false);

      final items = response
          .map((data) => InventoryModel.fromJson(data))
          .toList();

      // Senior Dev Tech: Force sync the cache so Isar picks up new fields like image_url immediately
      await IsarService.saveInventoryItems(items);
      
      return items;
    } on PostgrestException catch (e) {
      throw DataException('Failed to fetch inventory items: ${e.message}', code: e.code);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw DataException('Failed to fetch inventory items: $e');
    }
  }

  @override
  Stream<List<InventoryModel>> watchInventory() {
    // Create a merged stream: Isar local cache + Supabase real-time
    // We use a StreamController to merge two streams in parallel.
    // Bug Fix: Using `yield* IsarService.watchInventory()` was WRONG because
    // Isar returns an INFINITE stream, so code after it was NEVER reached.
    final controller = StreamController<List<InventoryModel>>();

    // Stream 1: Isar local cache (instant, offline-first)
    final isarSub = IsarService.watchInventory().listen(
      (items) => controller.add(items),
      onError: (e) => controller.addError(e),
    );

    // Stream 2: Supabase real-time (live data from web)
    final remoteStream = _client
        .from('inventory')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          final items = data
              .map((json) => InventoryModel.fromJson(json))
              .toList();
          // Update Isar cache in the background
          IsarService.saveInventoryItems(items);
          return items;
        });

    final remoteSub = remoteStream.listen(
      (items) => controller.add(items),
      onError: (e) {
        debugPrint('DEBUG: Supabase stream error: $e');
        controller.addError(e);
      },
    );

    controller.onCancel = () {
      isarSub.cancel();
      remoteSub.cancel();
    };

    return controller.stream;

  }

  @override
  Future<InventoryModel> getItemById(int id) async {
    try {
      final response = await _client
          .from('inventory')
          .select()
          .eq('id', id)
          .single();

      return InventoryModel.fromJson(response);
    } catch (e) {
      throw DataException('Failed to fetch inventory item: $e');
    }
  }

  @override
  Future<List<InventoryModel>> getItemsByCategory(String category) async {
    try {
      final response = await _client
          .from('inventory')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return response
          .map((data) => InventoryModel.fromJson(data))
          .toList();
    } catch (e) {
      throw DataException('Failed to fetch inventory items by category: $e');
    }
  }

  @override
  Future<List<InventoryModel>> searchItems(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final response = await _client
          .from('inventory')
          .select()
          .or('item_name.ilike.%${lowerQuery}%,category.ilike.%${lowerQuery}%')
          .order('created_at', ascending: false);

      return response
          .map((data) => InventoryModel.fromJson(data))
          .toList();
    } catch (e) {
      throw DataException('Failed to search inventory items: $e');
    }
  }
}

// Repository provider for inventory operations
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final supabaseClient = ref.read(AppProviders.supabaseClientProvider);
  return SupabaseInventoryRepository(supabaseClient);
});

// Stream provider for real-time inventory updates
final inventoryItemsProvider = StreamProvider<List<InventoryModel>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.watchInventory();
});

// Computed providers for filtered inventory
final activeInventoryItemsProvider = Provider<List<InventoryModel>>((ref) {
  final inventoryAsync = ref.watch(inventoryItemsProvider);
  
  return inventoryAsync.when(
    data: (items) => items.where((item) => item.status == 'active').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final lowStockInventoryItemsProvider = Provider<List<InventoryModel>>((ref) {
  final inventoryAsync = ref.watch(inventoryItemsProvider);
  
  return inventoryAsync.when(
    data: (items) => items.where((item) => item.quantity < 10).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Search provider
final filteredInventoryItemsProvider = Provider.family<List<InventoryModel>, String>((ref, searchQuery) {
  final allItemsAsync = ref.watch(inventoryItemsProvider);
  
  return allItemsAsync.when(
    data: (items) {
      if (searchQuery.isEmpty) return items;
      
      final query = searchQuery.toLowerCase();
      return items.where((item) {
        return item.name.toLowerCase().contains(query) ||
               item.code.toLowerCase().contains(query) ||
               item.category.toLowerCase().contains(query);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
