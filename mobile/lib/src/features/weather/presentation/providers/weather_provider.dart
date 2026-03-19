import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/weather_data.dart';
import '../../data/repositories/weather_repository.dart';

part 'weather_provider.g.dart';

@riverpod
class WeatherController extends _$WeatherController {
  final WeatherRepository _repository = WeatherRepository();

  @override
  Future<WeatherData> build() async {
    return _updateWeather();
  }

  Future<WeatherData> _updateWeather() async {
    try {
      // 1. Get Coordinates (Tactical Location Pulse)
      Position? position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 5),
            );
          }
        }
      } catch (e) {
        print('📡 Weather: Location access failed, using default coords. $e');
      }

      // Default to Manila coords if location fails
      final lat = position?.latitude ?? 14.5995;
      final lon = position?.longitude ?? 120.9842;

      return await _repository.fetchWeather(lat, lon);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _updateWeather());
  }
}
