// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'572b9bf99a814f1240394282388546d70bab544c';

/// 🛡️ THE MASTER AUTH PROVIDER
/// Aliased for backward compatibility and to provide a clean `AsyncValue` of [AuthState].
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeProvider<AsyncValue<AuthState>>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateRef = AutoDisposeProviderRef<AsyncValue<AuthState>>;
String _$currentUserHash() => r'3c7e0b6439561f76ae797b88d5551ff1aa96734b';

/// 👤 THE USER IDENTITY PROVIDER — only after admin approval (profile status `active`).
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<UserModel?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserRef = AutoDisposeProviderRef<UserModel?>;
String _$authLoadingHash() => r'c0fe76cf3dd9698e1c538c3b0b3d78eec6b98dd1';

/// ⏳ THE GLOBAL LOADING PROVIDER
///
/// Copied from [authLoading].
@ProviderFor(authLoading)
final authLoadingProvider = AutoDisposeProvider<bool>.internal(
  authLoading,
  name: r'authLoadingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthLoadingRef = AutoDisposeProviderRef<bool>;
String _$hasActiveAccessHash() => r'5402fe0e7e6449b60dbffee2c928c884a8fe1504';

/// 🏗️ THE ACCESS PERMISSION PROVIDER
///
/// Copied from [hasActiveAccess].
@ProviderFor(hasActiveAccess)
final hasActiveAccessProvider = AutoDisposeProvider<bool>.internal(
  hasActiveAccess,
  name: r'hasActiveAccessProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasActiveAccessHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasActiveAccessRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
