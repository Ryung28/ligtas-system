import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../../domain/entities/weather_data.dart';

class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherControllerProvider);

    return weatherAsync.when(
      data: (weather) => _WeatherContent(weather: weather),
      loading: () => const _WeatherLoading(),
      error: (err, stack) => _WeatherError(onRetry: () => ref.read(weatherControllerProvider.notifier).refresh()),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final WeatherData weather;
  const _WeatherContent({required this.weather});

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code >= 1 && code <= 3) return Icons.wb_cloudy_rounded;
    if (code >= 45 && code <= 48) return Icons.filter_drama_rounded;
    if (code >= 51 && code <= 67) return Icons.beach_access_rounded;
    if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 82) return Icons.umbrella_rounded;
    if (code >= 95) return Icons.thunderstorm_rounded;
    return Icons.cloud_queue_rounded;
  }

  String _getWeatherDesc(int code) {
    if (code == 0) return 'Clear Sky';
    if (code >= 1 && code <= 3) return 'Partly Cloudy';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 67) return 'Drizzle';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Cloudy';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF93C5FD), Colors.white],
          stops: [0.0, 0.4, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.cityName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    _getWeatherDesc(weather.weatherCode),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Icon(
                _getWeatherIcon(weather.weatherCode),
                size: 48,
                color: Colors.white,
              ),
            ],
          ),
          const Gap(24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${weather.temperature.toStringAsFixed(1)}°',
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Celsius',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          if (weather.isOffline) ...[
            const Gap(16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 12, color: Color(0xFF64748B)),
                  const Gap(6),
                  Text(
                    'Last updated: ${DateFormat('hh:mm a').format(weather.lastUpdated)}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeatherLoading extends StatelessWidget {
  const _WeatherLoading();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _WeatherError extends StatelessWidget {
  final VoidCallback onRetry;
  const _WeatherError({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 32),
          const Gap(12),
          Text(
            'Weather Sync Failed',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF991B1B)),
          ),
          TextButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}
