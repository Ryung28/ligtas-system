// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeatherDataImpl _$$WeatherDataImplFromJson(Map<String, dynamic> json) =>
    _$WeatherDataImpl(
      temperature: (json['temperature'] as num).toDouble(),
      weatherCode: (json['weatherCode'] as num).toInt(),
      cityName: json['cityName'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isOffline: json['isOffline'] as bool? ?? false,
    );

Map<String, dynamic> _$$WeatherDataImplToJson(_$WeatherDataImpl instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'weatherCode': instance.weatherCode,
      'cityName': instance.cityName,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'isOffline': instance.isOffline,
    };
