import 'package:isar/isar.dart';
import '../../domain/entities/weather_data.dart';

part 'weather_isar_model.g.dart';

@collection
class WeatherIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String cityName;

  late double temperature;
  late int weatherCode;
  late DateTime lastUpdated;

  WeatherData toEntity() {
    return WeatherData(
      temperature: temperature,
      weatherCode: weatherCode,
      cityName: cityName,
      lastUpdated: lastUpdated,
      isOffline: true,
    );
  }

  static WeatherIsar fromEntity(WeatherData entity) {
    return WeatherIsar()
      ..cityName = entity.cityName
      ..temperature = entity.temperature
      ..weatherCode = entity.weatherCode
      ..lastUpdated = entity.lastUpdated;
  }
}
