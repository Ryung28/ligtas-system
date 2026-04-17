// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manager_action_validation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$managerActionCanSubmitHash() =>
    r'ede956a40ef18609df2dc7d777426ac718991c3a';

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

/// Single, computed gate for submit eligibility.
/// Every mode has its own required-field set derived from the controller state.
/// The submit button only reads this — it has zero validation logic of its own.
///
/// Copied from [managerActionCanSubmit].
@ProviderFor(managerActionCanSubmit)
const managerActionCanSubmitProvider = ManagerActionCanSubmitFamily();

/// Single, computed gate for submit eligibility.
/// Every mode has its own required-field set derived from the controller state.
/// The submit button only reads this — it has zero validation logic of its own.
///
/// Copied from [managerActionCanSubmit].
class ManagerActionCanSubmitFamily extends Family<bool> {
  /// Single, computed gate for submit eligibility.
  /// Every mode has its own required-field set derived from the controller state.
  /// The submit button only reads this — it has zero validation logic of its own.
  ///
  /// Copied from [managerActionCanSubmit].
  const ManagerActionCanSubmitFamily();

  /// Single, computed gate for submit eligibility.
  /// Every mode has its own required-field set derived from the controller state.
  /// The submit button only reads this — it has zero validation logic of its own.
  ///
  /// Copied from [managerActionCanSubmit].
  ManagerActionCanSubmitProvider call(
    InventoryItem item,
  ) {
    return ManagerActionCanSubmitProvider(
      item,
    );
  }

  @override
  ManagerActionCanSubmitProvider getProviderOverride(
    covariant ManagerActionCanSubmitProvider provider,
  ) {
    return call(
      provider.item,
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
  String? get name => r'managerActionCanSubmitProvider';
}

/// Single, computed gate for submit eligibility.
/// Every mode has its own required-field set derived from the controller state.
/// The submit button only reads this — it has zero validation logic of its own.
///
/// Copied from [managerActionCanSubmit].
class ManagerActionCanSubmitProvider extends AutoDisposeProvider<bool> {
  /// Single, computed gate for submit eligibility.
  /// Every mode has its own required-field set derived from the controller state.
  /// The submit button only reads this — it has zero validation logic of its own.
  ///
  /// Copied from [managerActionCanSubmit].
  ManagerActionCanSubmitProvider(
    InventoryItem item,
  ) : this._internal(
          (ref) => managerActionCanSubmit(
            ref as ManagerActionCanSubmitRef,
            item,
          ),
          from: managerActionCanSubmitProvider,
          name: r'managerActionCanSubmitProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$managerActionCanSubmitHash,
          dependencies: ManagerActionCanSubmitFamily._dependencies,
          allTransitiveDependencies:
              ManagerActionCanSubmitFamily._allTransitiveDependencies,
          item: item,
        );

  ManagerActionCanSubmitProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.item,
  }) : super.internal();

  final InventoryItem item;

  @override
  Override overrideWith(
    bool Function(ManagerActionCanSubmitRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ManagerActionCanSubmitProvider._internal(
        (ref) => create(ref as ManagerActionCanSubmitRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        item: item,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _ManagerActionCanSubmitProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ManagerActionCanSubmitProvider && other.item == item;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, item.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ManagerActionCanSubmitRef on AutoDisposeProviderRef<bool> {
  /// The parameter `item` of this provider.
  InventoryItem get item;
}

class _ManagerActionCanSubmitProviderElement
    extends AutoDisposeProviderElement<bool> with ManagerActionCanSubmitRef {
  _ManagerActionCanSubmitProviderElement(super.provider);

  @override
  InventoryItem get item => (origin as ManagerActionCanSubmitProvider).item;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
