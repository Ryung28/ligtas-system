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
    r'458b5e8134fd68ea9cadaab56e3d3509353171cc';

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
String _$resourceAnomaliesHash() => r'5faf7ce3c277eea7af732d150ef26634cbba6452';

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
String _$analystDashboardControllerHash() =>
    r'5191730fd7522c7deffcd173460a14b8258d1702';

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
