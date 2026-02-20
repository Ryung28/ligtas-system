// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LigtasQrPayloadImpl _$$LigtasQrPayloadImplFromJson(
        Map<String, dynamic> json) =>
    _$LigtasQrPayloadImpl(
      protocol: json['protocol'] as String,
      version: json['version'] as String,
      action: json['action'] as String,
      itemId: (json['itemId'] as num).toInt(),
      itemName: json['itemName'] as String,
    );

Map<String, dynamic> _$$LigtasQrPayloadImplToJson(
        _$LigtasQrPayloadImpl instance) =>
    <String, dynamic>{
      'protocol': instance.protocol,
      'version': instance.version,
      'action': instance.action,
      'itemId': instance.itemId,
      'itemName': instance.itemName,
    };
