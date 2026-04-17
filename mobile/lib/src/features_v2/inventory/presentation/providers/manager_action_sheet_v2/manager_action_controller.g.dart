// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manager_action_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$managerActionControllerHash() =>
    r'f8f721483defc2d159df1bb2608d62d65963e434';

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

abstract class _$ManagerActionController
    extends BuildlessAutoDisposeNotifier<ManagerActionFormState> {
  late final InventoryItem item;

  ManagerActionFormState build(
    InventoryItem item,
  );
}

/// Orchestrates all state mutations and async actions for the Manager Action
/// Sheet V2. Widgets call setters here — never Supabase directly.
///
/// Copied from [ManagerActionController].
@ProviderFor(ManagerActionController)
const managerActionControllerProvider = ManagerActionControllerFamily();

/// Orchestrates all state mutations and async actions for the Manager Action
/// Sheet V2. Widgets call setters here — never Supabase directly.
///
/// Copied from [ManagerActionController].
class ManagerActionControllerFamily extends Family<ManagerActionFormState> {
  /// Orchestrates all state mutations and async actions for the Manager Action
  /// Sheet V2. Widgets call setters here — never Supabase directly.
  ///
  /// Copied from [ManagerActionController].
  const ManagerActionControllerFamily();

  /// Orchestrates all state mutations and async actions for the Manager Action
  /// Sheet V2. Widgets call setters here — never Supabase directly.
  ///
  /// Copied from [ManagerActionController].
  ManagerActionControllerProvider call(
    InventoryItem item,
  ) {
    return ManagerActionControllerProvider(
      item,
    );
  }

  @override
  ManagerActionControllerProvider getProviderOverride(
    covariant ManagerActionControllerProvider provider,
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
  String? get name => r'managerActionControllerProvider';
}

/// Orchestrates all state mutations and async actions for the Manager Action
/// Sheet V2. Widgets call setters here — never Supabase directly.
///
/// Copied from [ManagerActionController].
class ManagerActionControllerProvider extends AutoDisposeNotifierProviderImpl<
    ManagerActionController, ManagerActionFormState> {
  /// Orchestrates all state mutations and async actions for the Manager Action
  /// Sheet V2. Widgets call setters here — never Supabase directly.
  ///
  /// Copied from [ManagerActionController].
  ManagerActionControllerProvider(
    InventoryItem item,
  ) : this._internal(
          () => ManagerActionController()..item = item,
          from: managerActionControllerProvider,
          name: r'managerActionControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$managerActionControllerHash,
          dependencies: ManagerActionControllerFamily._dependencies,
          allTransitiveDependencies:
              ManagerActionControllerFamily._allTransitiveDependencies,
          item: item,
        );

  ManagerActionControllerProvider._internal(
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
  ManagerActionFormState runNotifierBuild(
    covariant ManagerActionController notifier,
  ) {
    return notifier.build(
      item,
    );
  }

  @override
  Override overrideWith(ManagerActionController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ManagerActionControllerProvider._internal(
        () => create()..item = item,
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
  AutoDisposeNotifierProviderElement<ManagerActionController,
      ManagerActionFormState> createElement() {
    return _ManagerActionControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ManagerActionControllerProvider && other.item == item;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, item.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ManagerActionControllerRef
    on AutoDisposeNotifierProviderRef<ManagerActionFormState> {
  /// The parameter `item` of this provider.
  InventoryItem get item;
}

class _ManagerActionControllerProviderElement
    extends AutoDisposeNotifierProviderElement<ManagerActionController,
        ManagerActionFormState> with ManagerActionControllerRef {
  _ManagerActionControllerProviderElement(super.provider);

  @override
  InventoryItem get item => (origin as ManagerActionControllerProvider).item;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
