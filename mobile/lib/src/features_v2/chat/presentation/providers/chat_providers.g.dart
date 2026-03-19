// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatRepositoryHash() => r'fa9ed843561cc08466881750b7eed576cfbfa8ec';

/// See also [chatRepository].
@ProviderFor(chatRepository)
final chatRepositoryProvider = Provider<ChatRepository>.internal(
  chatRepository,
  name: r'chatRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ChatRepositoryRef = ProviderRef<ChatRepository>;
String _$chatSyncStreamHash() => r'112685bbb821eae063c858c071a4f0ff1b934e07';

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

/// See also [chatSyncStream].
@ProviderFor(chatSyncStream)
const chatSyncStreamProvider = ChatSyncStreamFamily();

/// See also [chatSyncStream].
class ChatSyncStreamFamily extends Family<AsyncValue<List<ChatMessage>>> {
  /// See also [chatSyncStream].
  const ChatSyncStreamFamily();

  /// See also [chatSyncStream].
  ChatSyncStreamProvider call(
    String roomId,
  ) {
    return ChatSyncStreamProvider(
      roomId,
    );
  }

  @override
  ChatSyncStreamProvider getProviderOverride(
    covariant ChatSyncStreamProvider provider,
  ) {
    return call(
      provider.roomId,
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
  String? get name => r'chatSyncStreamProvider';
}

/// See also [chatSyncStream].
class ChatSyncStreamProvider extends StreamProvider<List<ChatMessage>> {
  /// See also [chatSyncStream].
  ChatSyncStreamProvider(
    String roomId,
  ) : this._internal(
          (ref) => chatSyncStream(
            ref as ChatSyncStreamRef,
            roomId,
          ),
          from: chatSyncStreamProvider,
          name: r'chatSyncStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatSyncStreamHash,
          dependencies: ChatSyncStreamFamily._dependencies,
          allTransitiveDependencies:
              ChatSyncStreamFamily._allTransitiveDependencies,
          roomId: roomId,
        );

  ChatSyncStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
  }) : super.internal();

  final String roomId;

  @override
  Override overrideWith(
    Stream<List<ChatMessage>> Function(ChatSyncStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatSyncStreamProvider._internal(
        (ref) => create(ref as ChatSyncStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
      ),
    );
  }

  @override
  StreamProviderElement<List<ChatMessage>> createElement() {
    return _ChatSyncStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatSyncStreamProvider && other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChatSyncStreamRef on StreamProviderRef<List<ChatMessage>> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _ChatSyncStreamProviderElement
    extends StreamProviderElement<List<ChatMessage>> with ChatSyncStreamRef {
  _ChatSyncStreamProviderElement(super.provider);

  @override
  String get roomId => (origin as ChatSyncStreamProvider).roomId;
}

String _$chatSessionHash() => r'50ce93205e3a9504df02adb59e2dbbe8c45175b8';

abstract class _$ChatSession
    extends BuildlessAutoDisposeNotifier<List<ChatMessage>> {
  late final String roomId;

  List<ChatMessage> build(
    String roomId,
  );
}

/// See also [ChatSession].
@ProviderFor(ChatSession)
const chatSessionProvider = ChatSessionFamily();

/// See also [ChatSession].
class ChatSessionFamily extends Family<List<ChatMessage>> {
  /// See also [ChatSession].
  const ChatSessionFamily();

  /// See also [ChatSession].
  ChatSessionProvider call(
    String roomId,
  ) {
    return ChatSessionProvider(
      roomId,
    );
  }

  @override
  ChatSessionProvider getProviderOverride(
    covariant ChatSessionProvider provider,
  ) {
    return call(
      provider.roomId,
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
  String? get name => r'chatSessionProvider';
}

/// See also [ChatSession].
class ChatSessionProvider
    extends AutoDisposeNotifierProviderImpl<ChatSession, List<ChatMessage>> {
  /// See also [ChatSession].
  ChatSessionProvider(
    String roomId,
  ) : this._internal(
          () => ChatSession()..roomId = roomId,
          from: chatSessionProvider,
          name: r'chatSessionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatSessionHash,
          dependencies: ChatSessionFamily._dependencies,
          allTransitiveDependencies:
              ChatSessionFamily._allTransitiveDependencies,
          roomId: roomId,
        );

  ChatSessionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
  }) : super.internal();

  final String roomId;

  @override
  List<ChatMessage> runNotifierBuild(
    covariant ChatSession notifier,
  ) {
    return notifier.build(
      roomId,
    );
  }

  @override
  Override overrideWith(ChatSession Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatSessionProvider._internal(
        () => create()..roomId = roomId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ChatSession, List<ChatMessage>>
      createElement() {
    return _ChatSessionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatSessionProvider && other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChatSessionRef on AutoDisposeNotifierProviderRef<List<ChatMessage>> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _ChatSessionProviderElement
    extends AutoDisposeNotifierProviderElement<ChatSession, List<ChatMessage>>
    with ChatSessionRef {
  _ChatSessionProviderElement(super.provider);

  @override
  String get roomId => (origin as ChatSessionProvider).roomId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
