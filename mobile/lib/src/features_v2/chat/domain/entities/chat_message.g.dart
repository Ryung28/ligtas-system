// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String? ?? '',
      roomId: json['roomId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      status: $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
          MessageStatus.sent,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
      'status': _$MessageStatusEnumMap[instance.status]!,
    };

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.error: 'error',
};
