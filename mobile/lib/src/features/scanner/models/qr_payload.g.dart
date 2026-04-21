// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EquipmentPayloadImpl _$$EquipmentPayloadImplFromJson(
        Map<String, dynamic> json) =>
    _$EquipmentPayloadImpl(
      protocol: json['protocol'] as String,
      version: json['version'] as String,
      action: json['action'] as String,
      itemId: (json['itemId'] as num).toInt(),
      itemName: json['itemName'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$EquipmentPayloadImplToJson(
        _$EquipmentPayloadImpl instance) =>
    <String, dynamic>{
      'protocol': instance.protocol,
      'version': instance.version,
      'action': instance.action,
      'itemId': instance.itemId,
      'itemName': instance.itemName,
      'runtimeType': instance.$type,
    };

_$StationPayloadImpl _$$StationPayloadImplFromJson(Map<String, dynamic> json) =>
    _$StationPayloadImpl(
      stationId: json['stationId'] as String,
      locationName: json['locationName'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$StationPayloadImplToJson(
        _$StationPayloadImpl instance) =>
    <String, dynamic>{
      'stationId': instance.stationId,
      'locationName': instance.locationName,
      'runtimeType': instance.$type,
    };

_$PersonPayloadImpl _$$PersonPayloadImplFromJson(Map<String, dynamic> json) =>
    _$PersonPayloadImpl(
      personId: json['personId'] as String,
      personName: json['personName'] as String,
      role: json['role'] as String? ?? 'Field Staff',
      phone: json['phone'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PersonPayloadImplToJson(_$PersonPayloadImpl instance) =>
    <String, dynamic>{
      'personId': instance.personId,
      'personName': instance.personName,
      'role': instance.role,
      'phone': instance.phone,
      'runtimeType': instance.$type,
    };
