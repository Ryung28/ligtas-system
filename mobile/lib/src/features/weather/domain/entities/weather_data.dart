import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_data.freezed.dart';
part 'weather_data.g.dart';

@freezed
class WeatherData with _$WeatherData {
  const factory WeatherData({
    required double temperature,
    required int weatherCode,
    required String cityName,
    required DateTime lastUpdated,
    @Default(false) bool isOffline,
  }) = _WeatherData;

  factory WeatherData.fromJson(Map<String, dynamic> json) => _$WeatherDataFromJson(json);
}
