// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      organization: json['organization'] as String?,
      role: json['role'] as String? ?? 'viewer',
      status: json['status'] as String? ?? 'pending',
      providers: (json['providers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'display_name': instance.displayName,
      'phone_number': instance.phoneNumber,
      'organization': instance.organization,
      'role': instance.role,
      'status': instance.status,
      'providers': instance.providers,
    };
