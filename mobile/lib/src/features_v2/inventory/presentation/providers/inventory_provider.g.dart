// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inventoryRepositoryHash() =>
    r'a06d81e376acdfd683c90dc455cc9b6f2b2ce477';

/// See also [inventoryRepository].
@ProviderFor(inventoryRepository)
final inventoryRepositoryProvider =
    AutoDisposeProvider<IInventoryRepository>.internal(
  inventoryRepository,
  name: r'inventoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InventoryRepositoryRef = AutoDisposeProviderRef<IInventoryRepository>;
String _$globalSearchHash() => r'5f0f351e2326bce5ba14977d05e4d6720ca9099b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 🛡️ THE SEARCH BYPASS: Instantly searches the whole DB via Repository
///
/// Copied from [globalSearch].
@ProviderFor(globalSearch)
const globalSearchProvider = GlobalSearchFamily();

/// 🛡️ THE SEARCH BYPASS: Instantly searches the whole DB via Repository
///
/// Copied from [globalSearch].
class GlobalSearchFamily extends Family<AsyncValue<List<InventoryItem>>> {
  /// 🛡️ THE SEARCH BYPASS: Instantly searches the whole DB via Repository
  ///
  /// Copied from [globalSearch].
  const GlobalSearchFamily();

  /// 🛡️ THE SEARCH BYPASS: Instantly searches the whole DB via Repository
  ///
  /// Copied from [globalSearch].
  GlobalSearchProvider call(
    String query,
  ) {
    return GlobalSearchProvider(
      query,
    );
  }

  @override
  GlobalSearchProvider getProviderOverride(
    covariant GlobalSearchProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'globalSearchProvider';
}

/// 🛡️ THE SEARCH BYPASS: Instantly searches the whole DB via Repository
///
/// Copied from [globalSearch].
class GlobalSearchProvider
    extends AutoDisposeFutureProvider<List<InventoryItem>> {
  /// 🛡️ THE SEARCH BYPASS: Instantly searches the whole DB via Repository
  ///
  /// Copied from [globalSearch].
  GlobalSearchProvider(
    String query,
  ) : this._internal(
          (ref) => globalSearch(
            ref as GlobalSearchRef,
            query,
          ),
          from: globalSearchProvider,
          name: r'globalSearchProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$globalSearchHash,
          dependencies: GlobalSearchFamily._dependencies,
          allTransitiveDependencies:
              GlobalSearchFamily._allTransitiveDependencies,
          query: query,
        );

  GlobalSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<InventoryItem>> Function(GlobalSearchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GlobalSearchProvider._internal(
        (ref) => create(ref as GlobalSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<InventoryItem>> createElement() {
    return _GlobalSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GlobalSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GlobalSearchRef on AutoDisposeFutureProviderRef<List<InventoryItem>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _GlobalSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<InventoryItem>>
    with GlobalSearchRef {
  _GlobalSearchProviderElement(super.provider);

  @override
  String get query => (origin as GlobalSearchProvider).query;
}

String _$totalInventoryCountHash() =>
    r'263a3a6e4b21337c689131e430dbb950af32084f';

/// See also [totalInventoryCount].
@ProviderFor(totalInventoryCount)
final totalInventoryCountProvider = AutoDisposeFutureProvider<int>.internal(
  totalInventoryCount,
  name: r'totalInventoryCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalInventoryCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalInventoryCountRef = AutoDisposeFutureProviderRef<int>;
String _$allInventoryStreamHash() =>
    r'30f0991c8051d0419ab366c4409df629718a5d6c';

/// 🛡️ THE METRICS ENGINE: Streams the full inventory for dashboard statistics
///
/// Copied from [allInventoryStream].
@ProviderFor(allInventoryStream)
final allInventoryStreamProvider =
    AutoDisposeStreamProvider<List<InventoryItem>>.internal(
  allInventoryStream,
  name: r'allInventoryStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allInventoryStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllInventoryStreamRef
    = AutoDisposeStreamProviderRef<List<InventoryItem>>;
String _$inventoryItemStreamHash() =>
    r'08ba32827415d66bedf2072aeb12e5544dc1a177';

/// See also [inventoryItemStream].
@ProviderFor(inventoryItemStream)
const inventoryItemStreamProvider = InventoryItemStreamFamily();

/// See also [inventoryItemStream].
class InventoryItemStreamFamily extends Family<AsyncValue<InventoryItem?>> {
  /// See also [inventoryItemStream].
  const InventoryItemStreamFamily();

  /// See also [inventoryItemStream].
  InventoryItemStreamProvider call(
    int id,
  ) {
    return InventoryItemStreamProvider(
      id,
    );
  }

  @override
  InventoryItemStreamProvider getProviderOverride(
    covariant InventoryItemStreamProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'inventoryItemStreamProvider';
}

/// See also [inventoryItemStream].
class InventoryItemStreamProvider
    extends AutoDisposeStreamProvider<InventoryItem?> {
  /// See also [inventoryItemStream].
  InventoryItemStreamProvider(
    int id,
  ) : this._internal(
          (ref) => inventoryItemStream(
            ref as InventoryItemStreamRef,
            id,
          ),
          from: inventoryItemStreamProvider,
          name: r'inventoryItemStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inventoryItemStreamHash,
          dependencies: InventoryItemStreamFamily._dependencies,
          allTransitiveDependencies:
              InventoryItemStreamFamily._allTransitiveDependencies,
          id: id,
        );

  InventoryItemStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    Stream<InventoryItem?> Function(InventoryItemStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InventoryItemStreamProvider._internal(
        (ref) => create(ref as InventoryItemStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<InventoryItem?> createElement() {
    return _InventoryItemStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InventoryItemStreamProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InventoryItemStreamRef on AutoDisposeStreamProviderRef<InventoryItem?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _InventoryItemStreamProviderElement
    extends AutoDisposeStreamProviderElement<InventoryItem?>
    with InventoryItemStreamRef {
  _InventoryItemStreamProviderElement(super.provider);

  @override
  int get id => (origin as InventoryItemStreamProvider).id;
}

String _$filteredInventoryHash() => r'863fb05886e5d3ee0e43e84f323a299b756d572b';

/// See also [filteredInventory].
@ProviderFor(filteredInventory)
final filteredInventoryProvider =
    AutoDisposeProvider<AsyncValue<List<InventoryItem>>>.internal(
  filteredInventory,
  name: r'filteredInventoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredInventoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredInventoryRef
    = AutoDisposeProviderRef<AsyncValue<List<InventoryItem>>>;
String _$inventoryImageMapHash() => r'1d704297d90346528c5e26793389095cb426441c';

/// 🛡️ THE AUDIT RESOLVER: Optimized Map for constant-time (O(1)) asset resolution
/// Created specifically for the Auditor Terminal handles large log history efficiently.
///
/// Copied from [inventoryImageMap].
@ProviderFor(inventoryImageMap)
final inventoryImageMapProvider =
    AutoDisposeProvider<Map<int, String>>.internal(
  inventoryImageMap,
  name: r'inventoryImageMapProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryImageMapHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InventoryImageMapRef = AutoDisposeProviderRef<Map<int, String>>;
String _$inventoryCategoriesHash() =>
    r'db9e15704889ae6232a635079bf1b73360c2cd38';

/// Centralized categories for the ResQTrack inventory
///
/// Copied from [inventoryCategories].
@ProviderFor(inventoryCategories)
final inventoryCategoriesProvider = AutoDisposeProvider<List<String>>.internal(
  inventoryCategories,
  name: r'inventoryCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InventoryCategoriesRef = AutoDisposeProviderRef<List<String>>;
String _$categoryIconHash() => r'950df07d60fa984a0687a1c217d1fc1562fdf74b';

/// Dynamic Icon mapping for categories
///
/// Copied from [categoryIcon].
@ProviderFor(categoryIcon)
const categoryIconProvider = CategoryIconFamily();

/// Dynamic Icon mapping for categories
///
/// Copied from [categoryIcon].
class CategoryIconFamily extends Family<IconData> {
  /// Dynamic Icon mapping for categories
  ///
  /// Copied from [categoryIcon].
  const CategoryIconFamily();

  /// Dynamic Icon mapping for categories
  ///
  /// Copied from [categoryIcon].
  CategoryIconProvider call(
    String category,
  ) {
    return CategoryIconProvider(
      category,
    );
  }

  @override
  CategoryIconProvider getProviderOverride(
    covariant CategoryIconProvider provider,
  ) {
    return call(
      provider.category,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categoryIconProvider';
}

/// Dynamic Icon mapping for categories
///
/// Copied from [categoryIcon].
class CategoryIconProvider extends AutoDisposeProvider<IconData> {
  /// Dynamic Icon mapping for categories
  ///
  /// Copied from [categoryIcon].
  CategoryIconProvider(
    String category,
  ) : this._internal(
          (ref) => categoryIcon(
            ref as CategoryIconRef,
            category,
          ),
          from: categoryIconProvider,
          name: r'categoryIconProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryIconHash,
          dependencies: CategoryIconFamily._dependencies,
          allTransitiveDependencies:
              CategoryIconFamily._allTransitiveDependencies,
          category: category,
        );

  CategoryIconProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final String category;

  @override
  Override overrideWith(
    IconData Function(CategoryIconRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryIconProvider._internal(
        (ref) => create(ref as CategoryIconRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<IconData> createElement() {
    return _CategoryIconProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryIconProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoryIconRef on AutoDisposeProviderRef<IconData> {
  /// The parameter `category` of this provider.
  String get category;
}

class _CategoryIconProviderElement extends AutoDisposeProviderElement<IconData>
    with CategoryIconRef {
  _CategoryIconProviderElement(super.provider);

  @override
  String get category => (origin as CategoryIconProvider).category;
}

String _$inventoryNotifierHash() => r'5165bf28f2483d57551778dd36e20304ec6829dd';

/// The state of our Inventory List (Reactive & Streams)
/// 🚀 THE GOLD STANDARD: Paginated Inventory Notifier
/// Only holds the current "Window" of data in memory.
/// 🚀 THE GOLD STANDARD: Paginated Inventory Notifier
/// Only holds the current "Window" of data in memory.
///
/// Copied from [InventoryNotifier].
@ProviderFor(InventoryNotifier)
final inventoryNotifierProvider =
    AsyncNotifierProvider<InventoryNotifier, List<InventoryItem>>.internal(
  InventoryNotifier.new,
  name: r'inventoryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryNotifier = AsyncNotifier<List<InventoryItem>>;
String _$inventorySearchQueryHash() =>
    r'd0b0247265a6c55ece66c239c4cf8204bc24a099';

/// See also [InventorySearchQuery].
@ProviderFor(InventorySearchQuery)
final inventorySearchQueryProvider =
    AutoDisposeNotifierProvider<InventorySearchQuery, String>.internal(
  InventorySearchQuery.new,
  name: r'inventorySearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventorySearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventorySearchQuery = AutoDisposeNotifier<String>;
String _$selectedCategoryHash() => r'e62a93d3a7a9d6c5041bb9cab7d2c288bdfd020a';

/// See also [SelectedCategory].
@ProviderFor(SelectedCategory)
final selectedCategoryProvider =
    AutoDisposeNotifierProvider<SelectedCategory, String>.internal(
  SelectedCategory.new,
  name: r'selectedCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedCategory = AutoDisposeNotifier<String>;
String _$isScrollingFastHash() => r'09d5d15140dd25e8d6750c8f652c6884e393ad62';

/// See also [IsScrollingFast].
@ProviderFor(IsScrollingFast)
final isScrollingFastProvider =
    AutoDisposeNotifierProvider<IsScrollingFast, bool>.internal(
  IsScrollingFast.new,
  name: r'isScrollingFastProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isScrollingFastHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IsScrollingFast = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
