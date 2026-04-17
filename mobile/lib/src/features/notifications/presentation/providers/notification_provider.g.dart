// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadNotificationCountHash() =>
    r'c9eecdbc76b2b60eee26b366dc0602e9d7055579';

/// Provider for unread notification count (using RPC like web)
///
/// Copied from [unreadNotificationCount].
@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = AutoDisposeStreamProvider<int>.internal(
  unreadNotificationCount,
  name: r'unreadNotificationCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnreadNotificationCountRef = AutoDisposeStreamProviderRef<int>;
String _$systemNotificationsHash() =>
    r'5de01f0bafa41717553f008ea22b3bad2e243304';

/// Provider for fetching system notifications using repository pattern
///
/// Copied from [systemNotifications].
@ProviderFor(systemNotifications)
final systemNotificationsProvider =
    AutoDisposeFutureProvider<List<NotificationItem>>.internal(
  systemNotifications,
  name: r'systemNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$systemNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SystemNotificationsRef
    = AutoDisposeFutureProviderRef<List<NotificationItem>>;
String _$notificationRepositoryHash() =>
    r'c074cdb2ba4209a3ef964e424f6d6407f9da0e10';

/// Provider for notification repository
///
/// Copied from [notificationRepository].
@ProviderFor(notificationRepository)
final notificationRepositoryProvider =
    AutoDisposeProvider<NotificationRepository>.internal(
  notificationRepository,
  name: r'notificationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationRepositoryRef
    = AutoDisposeProviderRef<NotificationRepository>;
String _$markNotificationAsReadHash() =>
    r'd3ea6cd535aac1a0bc127e8cc3f216d8cdf292e9';

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

/// Provider for marking notification as read
///
/// Copied from [markNotificationAsRead].
@ProviderFor(markNotificationAsRead)
const markNotificationAsReadProvider = MarkNotificationAsReadFamily();

/// Provider for marking notification as read
///
/// Copied from [markNotificationAsRead].
class MarkNotificationAsReadFamily extends Family<AsyncValue<void>> {
  /// Provider for marking notification as read
  ///
  /// Copied from [markNotificationAsRead].
  const MarkNotificationAsReadFamily();

  /// Provider for marking notification as read
  ///
  /// Copied from [markNotificationAsRead].
  MarkNotificationAsReadProvider call(
    String notificationId,
  ) {
    return MarkNotificationAsReadProvider(
      notificationId,
    );
  }

  @override
  MarkNotificationAsReadProvider getProviderOverride(
    covariant MarkNotificationAsReadProvider provider,
  ) {
    return call(
      provider.notificationId,
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
  String? get name => r'markNotificationAsReadProvider';
}

/// Provider for marking notification as read
///
/// Copied from [markNotificationAsRead].
class MarkNotificationAsReadProvider extends AutoDisposeFutureProvider<void> {
  /// Provider for marking notification as read
  ///
  /// Copied from [markNotificationAsRead].
  MarkNotificationAsReadProvider(
    String notificationId,
  ) : this._internal(
          (ref) => markNotificationAsRead(
            ref as MarkNotificationAsReadRef,
            notificationId,
          ),
          from: markNotificationAsReadProvider,
          name: r'markNotificationAsReadProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$markNotificationAsReadHash,
          dependencies: MarkNotificationAsReadFamily._dependencies,
          allTransitiveDependencies:
              MarkNotificationAsReadFamily._allTransitiveDependencies,
          notificationId: notificationId,
        );

  MarkNotificationAsReadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.notificationId,
  }) : super.internal();

  final String notificationId;

  @override
  Override overrideWith(
    FutureOr<void> Function(MarkNotificationAsReadRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarkNotificationAsReadProvider._internal(
        (ref) => create(ref as MarkNotificationAsReadRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        notificationId: notificationId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _MarkNotificationAsReadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarkNotificationAsReadProvider &&
        other.notificationId == notificationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, notificationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MarkNotificationAsReadRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `notificationId` of this provider.
  String get notificationId;
}

class _MarkNotificationAsReadProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with MarkNotificationAsReadRef {
  _MarkNotificationAsReadProviderElement(super.provider);

  @override
  String get notificationId =>
      (origin as MarkNotificationAsReadProvider).notificationId;
}

String _$markAllNotificationsAsReadHash() =>
    r'16c261f8f7b96583c50f057416ddc5f89ea95f4b';

/// Provider for marking all notifications as read
///
/// Copied from [markAllNotificationsAsRead].
@ProviderFor(markAllNotificationsAsRead)
final markAllNotificationsAsReadProvider =
    AutoDisposeFutureProvider<void>.internal(
  markAllNotificationsAsRead,
  name: r'markAllNotificationsAsReadProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$markAllNotificationsAsReadHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MarkAllNotificationsAsReadRef = AutoDisposeFutureProviderRef<void>;
String _$deleteNotificationHash() =>
    r'9568b341be98918259076aa857f359f460afee35';

/// Provider for deleting notification
///
/// Copied from [deleteNotification].
@ProviderFor(deleteNotification)
const deleteNotificationProvider = DeleteNotificationFamily();

/// Provider for deleting notification
///
/// Copied from [deleteNotification].
class DeleteNotificationFamily extends Family<AsyncValue<void>> {
  /// Provider for deleting notification
  ///
  /// Copied from [deleteNotification].
  const DeleteNotificationFamily();

  /// Provider for deleting notification
  ///
  /// Copied from [deleteNotification].
  DeleteNotificationProvider call(
    String notificationId,
  ) {
    return DeleteNotificationProvider(
      notificationId,
    );
  }

  @override
  DeleteNotificationProvider getProviderOverride(
    covariant DeleteNotificationProvider provider,
  ) {
    return call(
      provider.notificationId,
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
  String? get name => r'deleteNotificationProvider';
}

/// Provider for deleting notification
///
/// Copied from [deleteNotification].
class DeleteNotificationProvider extends AutoDisposeFutureProvider<void> {
  /// Provider for deleting notification
  ///
  /// Copied from [deleteNotification].
  DeleteNotificationProvider(
    String notificationId,
  ) : this._internal(
          (ref) => deleteNotification(
            ref as DeleteNotificationRef,
            notificationId,
          ),
          from: deleteNotificationProvider,
          name: r'deleteNotificationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deleteNotificationHash,
          dependencies: DeleteNotificationFamily._dependencies,
          allTransitiveDependencies:
              DeleteNotificationFamily._allTransitiveDependencies,
          notificationId: notificationId,
        );

  DeleteNotificationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.notificationId,
  }) : super.internal();

  final String notificationId;

  @override
  Override overrideWith(
    FutureOr<void> Function(DeleteNotificationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeleteNotificationProvider._internal(
        (ref) => create(ref as DeleteNotificationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        notificationId: notificationId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _DeleteNotificationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteNotificationProvider &&
        other.notificationId == notificationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, notificationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DeleteNotificationRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `notificationId` of this provider.
  String get notificationId;
}

class _DeleteNotificationProviderElement
    extends AutoDisposeFutureProviderElement<void> with DeleteNotificationRef {
  _DeleteNotificationProviderElement(super.provider);

  @override
  String get notificationId =>
      (origin as DeleteNotificationProvider).notificationId;
}

String _$notificationRealtimeSyncHash() =>
    r'9adfa584ef8c4542aa02352fc21d5672423002db';

/// Provider for real-time notification sync
///
/// Copied from [NotificationRealtimeSync].
@ProviderFor(NotificationRealtimeSync)
final notificationRealtimeSyncProvider =
    AutoDisposeNotifierProvider<NotificationRealtimeSync, void>.internal(
  NotificationRealtimeSync.new,
  name: r'notificationRealtimeSyncProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationRealtimeSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationRealtimeSync = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
