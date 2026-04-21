// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyst_dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$watchActivityStreamHash() =>
    r'b6f1846081ae800a2b9bb42080dd7126d19c2159';

/// 🛰️ SENTINEL PULSE PROVIDER: Real-time logistical activity stream
///
/// Copied from [watchActivityStream].
@ProviderFor(watchActivityStream)
final watchActivityStreamProvider =
    AutoDisposeStreamProvider<List<ActivityEvent>>.internal(
  watchActivityStream,
  name: r'watchActivityStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchActivityStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WatchActivityStreamRef
    = AutoDisposeStreamProviderRef<List<ActivityEvent>>;
String _$watchMetricsStreamHash() =>
    r'd926e4fe7058d4d4d269f4e9000bafa2e6f044fe';

/// 🛰️ KPI PULSE PROVIDER: Real-time aggregated metrics stream
///
/// Copied from [watchMetricsStream].
@ProviderFor(watchMetricsStream)
final watchMetricsStreamProvider =
    AutoDisposeStreamProvider<AnalystMetrics>.internal(
  watchMetricsStream,
  name: r'watchMetricsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchMetricsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WatchMetricsStreamRef = AutoDisposeStreamProviderRef<AnalystMetrics>;
String _$analystMetricsHash() => r'c2750d8f547e10393ed3317c853e713d242809b5';

/// Individual Providers for Granular UI Control
///
/// Copied from [analystMetrics].
@ProviderFor(analystMetrics)
final analystMetricsProvider =
    AutoDisposeFutureProvider<AnalystMetrics>.internal(
  analystMetrics,
  name: r'analystMetricsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analystMetricsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AnalystMetricsRef = AutoDisposeFutureProviderRef<AnalystMetrics>;
String _$watchResourceAnomaliesHash() =>
    r'bb7381b924f1369b5550f797b13cdc9bc9af85d8';

/// See also [watchResourceAnomalies].
@ProviderFor(watchResourceAnomalies)
final watchResourceAnomaliesProvider =
    AutoDisposeStreamProvider<List<ResourceAnomaly>>.internal(
  watchResourceAnomalies,
  name: r'watchResourceAnomaliesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchResourceAnomaliesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WatchResourceAnomaliesRef
    = AutoDisposeStreamProviderRef<List<ResourceAnomaly>>;
String _$resourceAnomaliesHash() => r'a2d2b4d0ecb153521cb09e57bc79a54932ff3183';

/// See also [resourceAnomalies].
@ProviderFor(resourceAnomalies)
final resourceAnomaliesProvider =
    AutoDisposeFutureProvider<List<ResourceAnomaly>>.internal(
  resourceAnomalies,
  name: r'resourceAnomaliesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resourceAnomaliesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ResourceAnomaliesRef
    = AutoDisposeFutureProviderRef<List<ResourceAnomaly>>;
String _$activityStreamHash() => r'6dea85aeef788a3cc7e0e0f64da127180ace9e47';

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

/// See also [activityStream].
@ProviderFor(activityStream)
const activityStreamProvider = ActivityStreamFamily();

/// See also [activityStream].
class ActivityStreamFamily extends Family<AsyncValue<List<ActivityEvent>>> {
  /// See also [activityStream].
  const ActivityStreamFamily();

  /// See also [activityStream].
  ActivityStreamProvider call({
    bool liveOnly = false,
  }) {
    return ActivityStreamProvider(
      liveOnly: liveOnly,
    );
  }

  @override
  ActivityStreamProvider getProviderOverride(
    covariant ActivityStreamProvider provider,
  ) {
    return call(
      liveOnly: provider.liveOnly,
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
  String? get name => r'activityStreamProvider';
}

/// See also [activityStream].
class ActivityStreamProvider
    extends AutoDisposeFutureProvider<List<ActivityEvent>> {
  /// See also [activityStream].
  ActivityStreamProvider({
    bool liveOnly = false,
  }) : this._internal(
          (ref) => activityStream(
            ref as ActivityStreamRef,
            liveOnly: liveOnly,
          ),
          from: activityStreamProvider,
          name: r'activityStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activityStreamHash,
          dependencies: ActivityStreamFamily._dependencies,
          allTransitiveDependencies:
              ActivityStreamFamily._allTransitiveDependencies,
          liveOnly: liveOnly,
        );

  ActivityStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.liveOnly,
  }) : super.internal();

  final bool liveOnly;

  @override
  Override overrideWith(
    FutureOr<List<ActivityEvent>> Function(ActivityStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActivityStreamProvider._internal(
        (ref) => create(ref as ActivityStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        liveOnly: liveOnly,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ActivityEvent>> createElement() {
    return _ActivityStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityStreamProvider && other.liveOnly == liveOnly;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, liveOnly.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ActivityStreamRef on AutoDisposeFutureProviderRef<List<ActivityEvent>> {
  /// The parameter `liveOnly` of this provider.
  bool get liveOnly;
}

class _ActivityStreamProviderElement
    extends AutoDisposeFutureProviderElement<List<ActivityEvent>>
    with ActivityStreamRef {
  _ActivityStreamProviderElement(super.provider);

  @override
  bool get liveOnly => (origin as ActivityStreamProvider).liveOnly;
}

String _$analystRepositoryHash() => r'fcb8d209a75caf3f8ae2ee1049d0a2ba66bf50b1';

/// Repository Provider (will be implemented in data layer)
///
/// Copied from [analystRepository].
@ProviderFor(analystRepository)
final analystRepositoryProvider =
    AutoDisposeProvider<IAnalystRepository>.internal(
  analystRepository,
  name: r'analystRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analystRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AnalystRepositoryRef = AutoDisposeProviderRef<IAnalystRepository>;
String _$hubStockSnapshotHash() => r'f005cd05e3f3d257ed4d83719cca053cb8aa5e50';

/// 🛰️ HUB SNAPSHOT PROVIDER: Surgical lookup of a specific hub's stock distribution
///
/// Copied from [hubStockSnapshot].
@ProviderFor(hubStockSnapshot)
const hubStockSnapshotProvider = HubStockSnapshotFamily();

/// 🛰️ HUB SNAPSHOT PROVIDER: Surgical lookup of a specific hub's stock distribution
///
/// Copied from [hubStockSnapshot].
class HubStockSnapshotFamily extends Family<AsyncValue<Map<String, int>>> {
  /// 🛰️ HUB SNAPSHOT PROVIDER: Surgical lookup of a specific hub's stock distribution
  ///
  /// Copied from [hubStockSnapshot].
  const HubStockSnapshotFamily();

  /// 🛰️ HUB SNAPSHOT PROVIDER: Surgical lookup of a specific hub's stock distribution
  ///
  /// Copied from [hubStockSnapshot].
  HubStockSnapshotProvider call({
    required int itemId,
    required int warehouseId,
  }) {
    return HubStockSnapshotProvider(
      itemId: itemId,
      warehouseId: warehouseId,
    );
  }

  @override
  HubStockSnapshotProvider getProviderOverride(
    covariant HubStockSnapshotProvider provider,
  ) {
    return call(
      itemId: provider.itemId,
      warehouseId: provider.warehouseId,
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
  String? get name => r'hubStockSnapshotProvider';
}

/// 🛰️ HUB SNAPSHOT PROVIDER: Surgical lookup of a specific hub's stock distribution
///
/// Copied from [hubStockSnapshot].
class HubStockSnapshotProvider
    extends AutoDisposeFutureProvider<Map<String, int>> {
  /// 🛰️ HUB SNAPSHOT PROVIDER: Surgical lookup of a specific hub's stock distribution
  ///
  /// Copied from [hubStockSnapshot].
  HubStockSnapshotProvider({
    required int itemId,
    required int warehouseId,
  }) : this._internal(
          (ref) => hubStockSnapshot(
            ref as HubStockSnapshotRef,
            itemId: itemId,
            warehouseId: warehouseId,
          ),
          from: hubStockSnapshotProvider,
          name: r'hubStockSnapshotProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hubStockSnapshotHash,
          dependencies: HubStockSnapshotFamily._dependencies,
          allTransitiveDependencies:
              HubStockSnapshotFamily._allTransitiveDependencies,
          itemId: itemId,
          warehouseId: warehouseId,
        );

  HubStockSnapshotProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
    required this.warehouseId,
  }) : super.internal();

  final int itemId;
  final int warehouseId;

  @override
  Override overrideWith(
    FutureOr<Map<String, int>> Function(HubStockSnapshotRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HubStockSnapshotProvider._internal(
        (ref) => create(ref as HubStockSnapshotRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemId: itemId,
        warehouseId: warehouseId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, int>> createElement() {
    return _HubStockSnapshotProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HubStockSnapshotProvider &&
        other.itemId == itemId &&
        other.warehouseId == warehouseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);
    hash = _SystemHash.combine(hash, warehouseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin HubStockSnapshotRef on AutoDisposeFutureProviderRef<Map<String, int>> {
  /// The parameter `itemId` of this provider.
  int get itemId;

  /// The parameter `warehouseId` of this provider.
  int get warehouseId;
}

class _HubStockSnapshotProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, int>>
    with HubStockSnapshotRef {
  _HubStockSnapshotProviderElement(super.provider);

  @override
  int get itemId => (origin as HubStockSnapshotProvider).itemId;
  @override
  int get warehouseId => (origin as HubStockSnapshotProvider).warehouseId;
}

String _$stationManifestHash() => r'3e1012e4696a9564f7e7e2a31d7cffc97c4c5f6c';

/// See also [stationManifest].
@ProviderFor(stationManifest)
const stationManifestProvider = StationManifestFamily();

/// See also [stationManifest].
class StationManifestFamily
    extends Family<AsyncValue<List<StationManifestItem>>> {
  /// See also [stationManifest].
  const StationManifestFamily();

  /// See also [stationManifest].
  StationManifestProvider call({
    required String stationId,
  }) {
    return StationManifestProvider(
      stationId: stationId,
    );
  }

  @override
  StationManifestProvider getProviderOverride(
    covariant StationManifestProvider provider,
  ) {
    return call(
      stationId: provider.stationId,
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
  String? get name => r'stationManifestProvider';
}

/// See also [stationManifest].
class StationManifestProvider
    extends AutoDisposeFutureProvider<List<StationManifestItem>> {
  /// See also [stationManifest].
  StationManifestProvider({
    required String stationId,
  }) : this._internal(
          (ref) => stationManifest(
            ref as StationManifestRef,
            stationId: stationId,
          ),
          from: stationManifestProvider,
          name: r'stationManifestProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$stationManifestHash,
          dependencies: StationManifestFamily._dependencies,
          allTransitiveDependencies:
              StationManifestFamily._allTransitiveDependencies,
          stationId: stationId,
        );

  StationManifestProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.stationId,
  }) : super.internal();

  final String stationId;

  @override
  Override overrideWith(
    FutureOr<List<StationManifestItem>> Function(StationManifestRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StationManifestProvider._internal(
        (ref) => create(ref as StationManifestRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        stationId: stationId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<StationManifestItem>> createElement() {
    return _StationManifestProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StationManifestProvider && other.stationId == stationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, stationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StationManifestRef
    on AutoDisposeFutureProviderRef<List<StationManifestItem>> {
  /// The parameter `stationId` of this provider.
  String get stationId;
}

class _StationManifestProviderElement
    extends AutoDisposeFutureProviderElement<List<StationManifestItem>>
    with StationManifestRef {
  _StationManifestProviderElement(super.provider);

  @override
  String get stationId => (origin as StationManifestProvider).stationId;
}

String _$analystDashboardControllerHash() =>
    r'9546fa599dccad760e9889fc1f2c4946417639d2';

/// Master Controller: Aggregates all analyst dashboard data
/// Updated for Sentinel Real-Time Logistical Reactivity
///
/// Copied from [AnalystDashboardController].
@ProviderFor(AnalystDashboardController)
final analystDashboardControllerProvider = AutoDisposeAsyncNotifierProvider<
    AnalystDashboardController, AnalystDashboardState>.internal(
  AnalystDashboardController.new,
  name: r'analystDashboardControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analystDashboardControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AnalystDashboardController
    = AutoDisposeAsyncNotifier<AnalystDashboardState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
