// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_ledger_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemForensicsHash() => r'0af9b0d9fd6c8f0b98a818988d794cf6ed0fe621';

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

/// See also [itemForensics].
@ProviderFor(itemForensics)
const itemForensicsProvider = ItemForensicsFamily();

/// See also [itemForensics].
class ItemForensicsFamily extends Family<AsyncValue<List<ActivityEvent>>> {
  /// See also [itemForensics].
  const ItemForensicsFamily();

  /// See also [itemForensics].
  ItemForensicsProvider call(
    String itemId,
  ) {
    return ItemForensicsProvider(
      itemId,
    );
  }

  @override
  ItemForensicsProvider getProviderOverride(
    covariant ItemForensicsProvider provider,
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
  String? get name => r'itemForensicsProvider';
}

/// See also [itemForensics].
class ItemForensicsProvider
    extends AutoDisposeFutureProvider<List<ActivityEvent>> {
  /// See also [itemForensics].
  ItemForensicsProvider(
    String itemId,
  ) : this._internal(
          (ref) => itemForensics(
            ref as ItemForensicsRef,
            itemId,
          ),
          from: itemForensicsProvider,
          name: r'itemForensicsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemForensicsHash,
          dependencies: ItemForensicsFamily._dependencies,
          allTransitiveDependencies:
              ItemForensicsFamily._allTransitiveDependencies,
          itemId: itemId,
        );

  ItemForensicsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
  }) : super.internal();

  final String itemId;

  @override
  Override overrideWith(
    FutureOr<List<ActivityEvent>> Function(ItemForensicsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemForensicsProvider._internal(
        (ref) => create(ref as ItemForensicsRef),
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
  AutoDisposeFutureProviderElement<List<ActivityEvent>> createElement() {
    return _ItemForensicsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemForensicsProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ItemForensicsRef on AutoDisposeFutureProviderRef<List<ActivityEvent>> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _ItemForensicsProviderElement
    extends AutoDisposeFutureProviderElement<List<ActivityEvent>>
    with ItemForensicsRef {
  _ItemForensicsProviderElement(super.provider);

  @override
  String get itemId => (origin as ItemForensicsProvider).itemId;
}

String _$activityLedgerHash() => r'48197a8449d0e5bf182ca81a08402906b6d33fa3';

/// See also [ActivityLedger].
@ProviderFor(ActivityLedger)
final activityLedgerProvider = AutoDisposeAsyncNotifierProvider<ActivityLedger,
    List<ActivityEvent>>.internal(
  ActivityLedger.new,
  name: r'activityLedgerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activityLedgerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActivityLedger = AutoDisposeAsyncNotifier<List<ActivityEvent>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
