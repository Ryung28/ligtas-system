import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/weather_data.dart';
import '../models/weather_isar_model.dart';
import 'package:mobile/src/core/local_storage/isar_service.dart';

class WeatherRepository {
  final Dio _dio = Dio();
  final Isar _isar = IsarService.instance;

  Future<WeatherData> fetchWeather(double lat, double lon) async {
    const String cityName = 'Current Location'; // Default for live coordinates

    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,weather_code',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final current = response.data['current'];
        final data = WeatherData(
          temperature: (current['temperature_2m'] as num).toDouble(),
          weatherCode: current['weather_code'] as int,
          cityName: cityName,
          lastUpdated: DateTime.now(),
          isOffline: false,
        );

        // 🛡️ Offline-First: Cache successful result
        await _isar.writeTxn(() async {
          await _isar.weatherIsars.put(WeatherIsar.fromEntity(data));
        });

        return data;
      } else {
        throw Exception('API_ERR: Failed to fetch weather data');
      }
    } catch (e) {
      debugPrint('📡 Weather: Network fetch failed, checking Isar cache... $e');
      
      // 🛡️ Fallback to Isar
      final cached = await _isar.weatherIsars
          .filter()
          .cityNameEqualTo(cityName)
          .findFirst();

      if (cached != null) {
        return cached.toEntity();
      }

      rethrow; // No cache and no network
    }
  }
}
