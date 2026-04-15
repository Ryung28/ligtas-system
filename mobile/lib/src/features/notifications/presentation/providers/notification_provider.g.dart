// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadNotificationCountHash() =>
    r'63dbf1cd4e47521b9eaef7ef242fa4f3a844987e';

/// Provider for unread notification count
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
    r'39b14a8ea7f18bd99dedbc58566f07dcaba2bf11';

/// Provider for fetching system notifications
///
/// Copied from [systemNotifications].
@ProviderFor(systemNotifications)
final systemNotificationsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  systemNotifications,
  name: r'systemNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$systemNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SystemNotificationsRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
