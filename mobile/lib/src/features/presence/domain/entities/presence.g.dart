// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPresenceImpl _$$UserPresenceImplFromJson(Map<String, dynamic> json) =>
    _$UserPresenceImpl(
      userId: json['userId'] as String? ?? '',
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserPresenceImplToJson(_$UserPresenceImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'lastSeen': instance.lastSeen.toIso8601String(),
      'isOnline': instance.isOnline,
    };
