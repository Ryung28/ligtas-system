import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum MessageStatus { sending, sent, error }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    @Default('') String id,
    @Default('') String roomId,
    @Default('') String senderId,
    String? receiverId, 
    @Default('') String content,
    required DateTime createdAt,
    @Default(false) bool isRead,
    @Default(MessageStatus.sent) MessageStatus status,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);


  factory ChatMessage.fromSupabase(Map<String, dynamic> json) {
    String createdAtRaw = (json['created_at'] ?? DateTime.now().toIso8601String()).toString();
    
    // ── UTC Safe Parsing: Append 'Z' if missing offset to prevent 8-hour drift ──
    if (!createdAtRaw.contains('Z') && !createdAtRaw.contains('+')) {
      createdAtRaw = '${createdAtRaw}Z';
    }

    return ChatMessage(
      id: (json['id'] ?? '').toString(),
      roomId: (json['room_id'] ?? '').toString(),
      senderId: (json['sender_id'] ?? '').toString(),
      receiverId: json['receiver_id']?.toString(), // Explicitly nullable
      content: (json['content'] ?? '').toString(),
      createdAt: DateTime.parse(createdAtRaw).toUtc(),
      isRead: json['is_read'] == true,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
    );
  }
}

