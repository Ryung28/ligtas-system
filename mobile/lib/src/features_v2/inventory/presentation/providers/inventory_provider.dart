import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/core/local_storage/isar_service.dart';
import 'package:mobile/src/features/inventory/models/inventory_model.dart';
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
/// 🚀 THE GOLD STANDARD: Paginated Inventory Notifier
/// Only holds the current "Window" of data in memory.
/// 🚀 THE GOLD STANDARD: Paginated Inventory Notifier
/// Only holds the current "Window" of data in memory.
@Riverpod(keepAlive: true)
class InventoryNotifier extends _$InventoryNotifier {
  late final IInventoryRepository _repository;
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;
  static const String _cacheVersionKey = 'inventory_cache_version';
  static const int _currentCacheVersion = 8; // v8: active_inventory variants + qty_* per site; parent bucket columns

  @override
  Future<List<InventoryItem>> build() async {
    _repository = ref.watch(inventoryRepositoryProvider);
    final category = ref.watch(selectedCategoryProvider);
    
    // 🛡️ CACHE VERSION CHECK: Soft Migration
    // Instead of wiping the DB and leaving a blank screen, we just trigger a full refresh.
    final needsFullRefresh = await _checkCacheVersion();
    
    // 1. Reactive Listener: If local DB changes, refresh state (if on pg 1)
    ref.listen(allInventoryStreamProvider, (prev, next) async {
      if (_offset == 0 && next.hasValue) {
        final cat = ref.read(selectedCategoryProvider);
        try {
          state = AsyncValue.data(await _loadInitial(cat));
        } catch (e) {
          debugPrint('InventoryNotifier: stream-driven reload failed: $e');
        }
      }
    });

    // 2. Load what we have immediately (even if old)
    final localItems = await _loadInitial(category);
    
    // 3. BACKGROUND SYNC: Differential or Full
    Future.microtask(() async {
      try {
        final user = ref.read(currentUserProvider);
        final warehouseId = user?.canEdit ?? false ? null : user?.assignedWarehouse;
        
        // If we have data, try a differential sync (items changed in last 7 days)
        // If the cache was just updated, do a full fetch.
        final lastSync = needsFullRefresh ? null : DateTime.now().subtract(const Duration(days: 7));
        
        await _repository.fetchAll(warehouseId: warehouseId, updatedAfter: lastSync);
      } catch (e) {
        debugPrint('🛡️ Background Sync Failed (Ignored): $e');
      }
    });

    return localItems;
  }

  /// 🛡️ SOFT MIGRATION: Returns true if cache version changed.
  /// Does NOT clear the database to prevent a blank screen.
  Future<bool> _checkCacheVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedVersion = prefs.getInt(_cacheVersionKey) ?? 0;
    
    if (cachedVersion < _currentCacheVersion) {
      debugPrint('🛡️ Cache version outdated ($cachedVersion < $_currentCacheVersion). Triggering soft refresh...');
      await prefs.setInt(_cacheVersionKey, _currentCacheVersion);
      return true;
    }
    return false;
  }

  Future<List<InventoryItem>> _loadInitial(String category) async {
    _offset = 0;
    _hasMore = true;
    final items = await _repository.fetchLocalPaged(offset: _offset, limit: _pageSize, category: category);
    _hasMore = items.length == _pageSize;
    return items;
  }

  /// 🚀 INCREMENTAL HYDRATION: Fetch next chunk from local disk (~1.5ms)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    
    try {
      final category = ref.read(selectedCategoryProvider);
      final currentItems = state.value ?? [];
      _offset += _pageSize;
      
      final nextItems = await _repository.fetchLocalPaged(offset: _offset, limit: _pageSize, category: category);
      _hasMore = nextItems.length == _pageSize;
      
      state = AsyncValue.data([...currentItems, ...nextItems]);
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;

  /// Action: Find by QR Code
  Future<InventoryItem?> scanForId(String code) async {
    final user = ref.read(currentUserProvider);
    final warehouseId = user?.canEdit ?? false ? null : user?.assignedWarehouse;
    return _repository.findByQrCode(code, warehouseId: warehouseId);
  }

  /// Reload remotely and reset window
  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    final category = ref.read(selectedCategoryProvider);
    final warehouseId = user?.canEdit ?? false ? null : user?.assignedWarehouse;
    final previousItems = state.valueOrNull ?? const <InventoryItem>[];
    
    state = const AsyncLoading<List<InventoryItem>>().copyWithPrevious(state);
    try {
      // Force a full fetch on manual refresh
      await _repository.fetchAll(warehouseId: warehouseId);
      state = AsyncValue.data(await _loadInitial(category));
    } catch (e, st) {
      // 🛡️ RECOVERY: Prefer latest local snapshot; only surface error if no local data exists.
      final localFallback = await _loadInitial(category);
      if (localFallback.isNotEmpty || previousItems.isNotEmpty) {
        state = AsyncValue.data(localFallback.isNotEmpty ? localFallback : previousItems);
      } else {
        // Only then we pass the mapped failure to the UI
        state = AsyncValue.error(e, st);
      }
    }
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

  void update(String category) {
    if (state != category) {
      state = category;
      
      // 🛡️ SYNC FAILSAFE: When switching categories, trigger a silent sync
      // This ensures that if the category is empty locally, we try to fetch it from remote.
      final user = ref.read(currentUserProvider);
      final isManager = user?.canEdit ?? false;
      final warehouseId = isManager ? null : user?.assignedWarehouse;
      
      Future.microtask(() async {
        try {
          await ref.read(inventoryRepositoryProvider).fetchAll(warehouseId: warehouseId);
        } catch (e) {
          debugPrint('SelectedCategory silent sync failed: $e');
        }
      });
    }
  }
}

/// 🛡️ THE SEARCH BYPASS: Instantly searches the whole DB via Repository
@riverpod
Future<List<InventoryItem>> globalSearch(GlobalSearchRef ref, String query) async {
  if (query.isEmpty) return [];
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.searchLocal(query);
}

@riverpod
Future<int> totalInventoryCount(TotalInventoryCountRef ref) async {
  final inventory = ref.watch(allInventoryStreamProvider).valueOrNull ?? [];
  return inventory.length;
}

/// 🛡️ THE METRICS ENGINE: Streams the full inventory for dashboard statistics
@riverpod
Stream<List<InventoryItem>> allInventoryStream(AllInventoryStreamRef ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.watchLocal();
}

@riverpod
Stream<InventoryItem?> inventoryItemStream(InventoryItemStreamRef ref, int id) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.watchItem(id);
}

@riverpod
AsyncValue<List<InventoryItem>> filteredInventory(FilteredInventoryRef ref) {
  final searchQuery = ref.watch(inventorySearchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  // 🛡️ BRANCH 1: Active Global Search
  if (searchQuery.isNotEmpty) {
    return ref.watch(globalSearchProvider(searchQuery)).whenData((items) {
      return items.where((item) {
        return selectedCategory == 'All' || 
            item.category.trim().toLowerCase() == selectedCategory.trim().toLowerCase();
      }).toList();
    });
  }

  // 🛡️ BRANCH 2: Standard Browse (Global Local Filter)
  if (selectedCategory != 'All') {
    final allItemsAsync = ref.watch(allInventoryStreamProvider);
    return allItemsAsync.when(
      data: (items) => AsyncValue.data(
        items.where((item) => 
          item.category.trim().toLowerCase() == selectedCategory.trim().toLowerCase()
        ).toList()
      ),
      loading: () => const AsyncValue.loading(),
      error: (e, st) {
        // Stream can still error on rare Isar edge cases; degrade to paginated cache.
        final paginated = ref.watch(inventoryNotifierProvider);
        return paginated.when(
          data: (items) => AsyncValue.data(
            items
                .where(
                  (item) =>
                      item.category.trim().toLowerCase() ==
                      selectedCategory.trim().toLowerCase(),
                )
                .toList(),
          ),
          loading: () => const AsyncValue.loading(),
          // Avoid full-screen sync error for transient dual-source failures.
          error: (_, __) => const AsyncValue.data(<InventoryItem>[]),
        );
      },
    );
  }

  // 🛡️ BRANCH 3: Paginated 'All' View
  return ref.watch(inventoryNotifierProvider);
}

/// 🛡️ THE AUDIT RESOLVER: Optimized Map for constant-time (O(1)) asset resolution
/// Created specifically for the Auditor Terminal handles large log history efficiently.
@riverpod
Map<int, String> inventoryImageMap(InventoryImageMapRef ref) {
  final inventory = ref.watch(allInventoryStreamProvider).valueOrNull ?? [];
  return {for (var item in inventory) item.id: item.imageUrl ?? ''};
}

/// Centralized categories for the ResQTrack inventory
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
    'Goods',
  ];
}

/// Dynamic Icon mapping for categories
@riverpod
IconData categoryIcon(CategoryIconRef ref, String category) {
  final c = category.toLowerCase();
  
  if (c.contains('med')) return Icons.medical_services_rounded; // Web: Cross
  if (c.contains('tool')) return Icons.construction_rounded; // Web: Wrench
  if (c.contains('resc') || c.contains('safe') || c.contains('ppe') || c.contains('gear')) {
    return Icons.security_rounded; // Web: Shield
  }
  if (c.contains('comms') || c.contains('radio')) return Icons.settings_input_antenna_rounded;
  if (c.contains('vehi') || c.contains('truck')) return Icons.local_shipping_rounded;
  if (c.contains('logi') || c.contains('ware')) return Icons.warehouse_rounded;
  
  return Icons.inventory_2_outlined; // Web: Box
}

@riverpod
class IsScrollingFast extends _$IsScrollingFast {
  @override
  bool build() => false;

  void setFast(bool value) {
    if (state != value) state = value;
  }
}

/// 🛡️ THE DISTRIBUTED LOGISTICS ENGINE
/// Fetches the live registry of all valid Storage Hubs / Warehouses
class StorageHub {
  final int id;
  final String name;

  const StorageHub({
    required this.id,
    required this.name,
  });
}

final storageHubsProvider = FutureProvider<List<StorageHub>>((ref) async {
  final client = Supabase.instance.client;
  final response = await client
      .from('storage_locations')
      .select('id, location_name')
      .order('location_name');
      
  return (response as List).map((e) => StorageHub(
    id: e['id'] as int,
    name: e['location_name'] as String,
  )).toList();
});
