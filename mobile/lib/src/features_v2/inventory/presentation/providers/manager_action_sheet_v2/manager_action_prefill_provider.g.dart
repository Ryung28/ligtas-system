// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manager_action_prefill_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$managerStorageHubsHash() =>
    r'b29d0ef99d650cd68bf8b03b4134c3919345b409';

/// Cached list of storage hubs used by the Restock and Edit location dropdowns.
/// Kept separate from inventory_provider to avoid pulling this concern into
/// the main feed. Hits Supabase once per sheet lifecycle; Riverpod caches it.
///
/// Copied from [managerStorageHubs].
@ProviderFor(managerStorageHubs)
final managerStorageHubsProvider =
    AutoDisposeFutureProvider<List<StorageHub>>.internal(
  managerStorageHubs,
  name: r'managerStorageHubsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$managerStorageHubsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ManagerStorageHubsRef = AutoDisposeFutureProviderRef<List<StorageHub>>;
String _$managerEditAdminFieldsHash() =>
    r'71f812e52f12983417ae9562b510896e12e5740e';

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

/// Loads admin bucket fields for a single item — only called when the user
/// switches to Edit mode. The controller watches the isEditLoading flag instead
/// of this provider directly, so it can merge the result into its own state.
///
/// Copied from [managerEditAdminFields].
@ProviderFor(managerEditAdminFields)
const managerEditAdminFieldsProvider = ManagerEditAdminFieldsFamily();

/// Loads admin bucket fields for a single item — only called when the user
/// switches to Edit mode. The controller watches the isEditLoading flag instead
/// of this provider directly, so it can merge the result into its own state.
///
/// Copied from [managerEditAdminFields].
class ManagerEditAdminFieldsFamily
    extends Family<AsyncValue<InventoryAdminFields>> {
  /// Loads admin bucket fields for a single item — only called when the user
  /// switches to Edit mode. The controller watches the isEditLoading flag instead
  /// of this provider directly, so it can merge the result into its own state.
  ///
  /// Copied from [managerEditAdminFields].
  const ManagerEditAdminFieldsFamily();

  /// Loads admin bucket fields for a single item — only called when the user
  /// switches to Edit mode. The controller watches the isEditLoading flag instead
  /// of this provider directly, so it can merge the result into its own state.
  ///
  /// Copied from [managerEditAdminFields].
  ManagerEditAdminFieldsProvider call(
    int itemId,
  ) {
    return ManagerEditAdminFieldsProvider(
      itemId,
    );
  }

  @override
  ManagerEditAdminFieldsProvider getProviderOverride(
    covariant ManagerEditAdminFieldsProvider provider,
  ) {
    return call(
      provider.itemId,
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
  String? get name => r'managerEditAdminFieldsProvider';
}

/// Loads admin bucket fields for a single item — only called when the user
/// switches to Edit mode. The controller watches the isEditLoading flag instead
/// of this provider directly, so it can merge the result into its own state.
///
/// Copied from [managerEditAdminFields].
class ManagerEditAdminFieldsProvider
    extends AutoDisposeFutureProvider<InventoryAdminFields> {
  /// Loads admin bucket fields for a single item — only called when the user
  /// switches to Edit mode. The controller watches the isEditLoading flag instead
  /// of this provider directly, so it can merge the result into its own state.
  ///
  /// Copied from [managerEditAdminFields].
  ManagerEditAdminFieldsProvider(
    int itemId,
  ) : this._internal(
          (ref) => managerEditAdminFields(
            ref as ManagerEditAdminFieldsRef,
            itemId,
          ),
          from: managerEditAdminFieldsProvider,
          name: r'managerEditAdminFieldsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$managerEditAdminFieldsHash,
          dependencies: ManagerEditAdminFieldsFamily._dependencies,
          allTransitiveDependencies:
              ManagerEditAdminFieldsFamily._allTransitiveDependencies,
          itemId: itemId,
        );

  ManagerEditAdminFieldsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
  }) : super.internal();

  final int itemId;

  @override
  Override overrideWith(
    FutureOr<InventoryAdminFields> Function(ManagerEditAdminFieldsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ManagerEditAdminFieldsProvider._internal(
        (ref) => create(ref as ManagerEditAdminFieldsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemId: itemId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<InventoryAdminFields> createElement() {
    return _ManagerEditAdminFieldsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ManagerEditAdminFieldsProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ManagerEditAdminFieldsRef
    on AutoDisposeFutureProviderRef<InventoryAdminFields> {
  /// The parameter `itemId` of this provider.
  int get itemId;
}

class _ManagerEditAdminFieldsProviderElement
    extends AutoDisposeFutureProviderElement<InventoryAdminFields>
    with ManagerEditAdminFieldsRef {
  _ManagerEditAdminFieldsProviderElement(super.provider);

  @override
  int get itemId => (origin as ManagerEditAdminFieldsProvider).itemId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
