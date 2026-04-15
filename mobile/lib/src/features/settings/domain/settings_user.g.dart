// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsUserImpl _$$SettingsUserImplFromJson(Map<String, dynamic> json) =>
    _$SettingsUserImpl(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      lguName: json['lguName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? null,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSyncAt: json['lastSyncAt'] as String? ?? '',
    );

Map<String, dynamic> _$$SettingsUserImplToJson(_$SettingsUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'role': instance.role,
      'lguName': instance.lguName,
      'avatarUrl': instance.avatarUrl,
      'isOnline': instance.isOnline,
      'lastSyncAt': instance.lastSyncAt,
    };
