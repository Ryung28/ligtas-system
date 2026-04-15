// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$presenceRepositoryHash() =>
    r'3749981d93ac884c72703a4aa911080383b11d9f';

/// See also [presenceRepository].
@ProviderFor(presenceRepository)
final presenceRepositoryProvider =
    AutoDisposeProvider<IPresenceRepository>.internal(
  presenceRepository,
  name: r'presenceRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$presenceRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PresenceRepositoryRef = AutoDisposeProviderRef<IPresenceRepository>;
String _$presenceControllerHash() =>
    r'b271a6745cb9f65aa9c126254e02c6da2ffbb5d5';

/// See also [PresenceController].
@ProviderFor(PresenceController)
final presenceControllerProvider =
    NotifierProvider<PresenceController, bool>.internal(
  PresenceController.new,
  name: r'presenceControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$presenceControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PresenceController = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
