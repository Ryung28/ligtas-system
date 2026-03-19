import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../weather/presentation/providers/weather_provider.dart';

class DashboardHeader extends ConsumerWidget {
  final String userName;

  const DashboardHeader({super.key, required this.userName});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherControllerProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // User Greeting Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()} ${_getGreetingEmoji()}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B), // Slate Grey
                  letterSpacing: 0.5,
                ),
              ),
              const Gap(4),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A), // Deep Charcoal
                  letterSpacing: -1.2,
                ),
              ),
            ],
          ),
        ),

        // Silk Glass Weather Widget
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6), // Light glass
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    weatherAsync.when(
                      data: (w) => _getWeatherIcon(w.weatherCode),
                      loading: () => Icons.cloud_rounded,
                      error: (_, __) => Icons.cloud_off_rounded,
                    ),
                    color: const Color(0xFF0EA5E9), 
                    size: 22
                  ),
                  const Gap(10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherAsync.when(
                          data: (w) => '${w.temperature.toStringAsFixed(0)}°C',
                          loading: () => '--°C',
                          error: (_, __) => '!!°C',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
      ],
    );
  }

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
}
