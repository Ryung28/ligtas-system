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
String _$filteredInventoryHash() => r'8ad14a114800915884da50a5d2ded9d321b40adc';

/// See also [filteredInventory].
@ProviderFor(filteredInventory)
final filteredInventoryProvider =
    AutoDisposeProvider<List<InventoryItem>>.internal(
  filteredInventory,
  name: r'filteredInventoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredInventoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredInventoryRef = AutoDisposeProviderRef<List<InventoryItem>>;
String _$inventoryCategoriesHash() =>
    r'9ef8c7f092ce541cd3188cdb96eb9b2f4e6a84f7';

/// Centralized categories for the LIGTAS inventory
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
String _$categoryIconHash() => r'8cc107260b4e926555b7959d613f6e3c364d0747';

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

String _$inventoryNotifierHash() => r'8bf544cca9c991381e7391044a6df1888817c60b';

/// The state of our Inventory List (Reactive & Streams)
///
/// Copied from [InventoryNotifier].
@ProviderFor(InventoryNotifier)
final inventoryNotifierProvider = AutoDisposeStreamNotifierProvider<
    InventoryNotifier, List<InventoryItem>>.internal(
  InventoryNotifier.new,
  name: r'inventoryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryNotifier = AutoDisposeStreamNotifier<List<InventoryItem>>;
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
String _$selectedCategoryHash() => r'4ce0d9e92008c62a7e277d7f84845fd7c3ba046f';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
