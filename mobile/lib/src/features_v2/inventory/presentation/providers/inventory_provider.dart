import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../data/repositories/supabase_inventory_repository.dart';
import '../../data/sources/inventory_local_source.dart';

part 'inventory_provider.g.dart';

@riverpod
IInventoryRepository inventoryRepository(InventoryRepositoryRef ref) {
  final client = Supabase.instance.client;
  final local = InventoryLocalDataSource();
  return SupabaseInventoryRepository(client, local);
}

/// The state of our Inventory List (Reactive & Streams)
@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  late final IInventoryRepository _repository;

  @override
  Stream<List<InventoryItem>> build() async* {
    _repository = ref.watch(inventoryRepositoryProvider);
    
    // 1. Initial trigger: Remote fetch to update local sync
    _repository.fetchAll();

    // 🚀 NEW: Auto-Sync Loop (Realtime)
    // Subscribe to remote changes and keep local Isar updated
    final remoteSubscription = _repository.watchRemote().listen((_) {});
    ref.onDispose(() => remoteSubscription.cancel());

    // 2. Continuous Source: Watch the local database for UI updates
    yield* (_repository as SupabaseInventoryRepository).watchItems();
  }

  /// Action: Find by QR Code
  Future<InventoryItem?> scanForId(String code) async {
    return _repository.findByQrCode(code);
  }

  /// Reload remotely
  Future<void> refresh() async {
    await _repository.fetchAll();
  }
}

@riverpod
class InventorySearchQuery extends _$InventorySearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String build() => 'All';

  void update(String category) => state = category;
}

@riverpod
List<InventoryItem> filteredInventory(FilteredInventoryRef ref) {
  final inventoryAsync = ref.watch(inventoryNotifierProvider);
  final searchQuery = ref.watch(inventorySearchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return inventoryAsync.maybeWhen(
    data: (items) {
      final filtered = items.where((item) {
        final matchesSearch = searchQuery.isEmpty || 
            item.name.toLowerCase().contains(searchQuery) ||
            item.code.toLowerCase().contains(searchQuery) ||
            item.category.toLowerCase().contains(searchQuery);
        final matchesCategory = selectedCategory == 'All' || 
            item.category.trim().toLowerCase() == selectedCategory.trim().toLowerCase();
        return matchesSearch && matchesCategory;
      }).toList();

      // Senior Dev Tech: Sanitize data to prevent Duplicate Key/Hero crashes
      final uniqueItems = <int, InventoryItem>{};
      for (var item in filtered) {
        uniqueItems[item.id] = item;
      }
      return uniqueItems.values.toList();
    },
    orElse: () => [],
  );
}

/// Centralized categories for the LIGTAS inventory
@riverpod
List<String> inventoryCategories(InventoryCategoriesRef ref) {
  return [
    'All',
    'Rescue',
    'Medical',
    'Comms',
    'Vehicles',
    'Tools',
    'PPE',
    'Logistics',
  ];
}

/// Dynamic Icon mapping for categories
@riverpod
IconData categoryIcon(CategoryIconRef ref, String category) {
  final c = category.toLowerCase();
  if (c.contains('comms') || c.contains('radio')) return Icons.settings_input_antenna_rounded;
  if (c.contains('bolt') || c.contains('power') || c.contains('gen')) return Icons.bolt_rounded;
  if (c.contains('med') || c.contains('aid')) return Icons.medical_services_rounded;
  if (c.contains('dron') || c.contains('fly')) return Icons.flight_takeoff_rounded;
  if (c.contains('resc') || c.contains('life') || c.contains('safe')) return Icons.health_and_safety_rounded;
  if (c.contains('tool') || c.contains('work')) return Icons.construction_rounded;
  if (c.contains('vehi') || c.contains('truck')) return Icons.local_shipping_rounded;
  if (c.contains('ppe') || c.contains('gear')) return Icons.masks_rounded;
  if (c.contains('logi') || c.contains('ware')) return Icons.warehouse_rounded;
  return Icons.inventory_2_outlined;
}
