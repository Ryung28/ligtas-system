// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadChatCountHash() => r'580bd38f0cdae4401578ba61b0a35c44d9b6b11e';
/**
 * UnreadChatCount Provider
 * 
 * 🛠️ Patterns Applied: Realtime Stream Observation, Tactical Filtering
 * 
 * This provider listens to the 'chat_messages' table in realtime.
 * It counts all messages where:
 * 1. is_read = false
 * 2. receiver_id = current user's ID
 */
///
/// Copied from [unreadChatCount].
@ProviderFor(unreadChatCount)
final unreadChatCountProvider = AutoDisposeStreamProvider<int>.internal(
  unreadChatCount,
  name: r'unreadChatCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadChatCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnreadChatCountRef = AutoDisposeStreamProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
