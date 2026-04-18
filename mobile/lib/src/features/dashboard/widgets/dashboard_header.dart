import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../weather/presentation/providers/weather_provider.dart';
import '../../weather/domain/entities/weather_data.dart';
import '../../notifications/presentation/providers/notification_provider.dart';

class DashboardHeader extends ConsumerWidget {
  final String userName;

  const DashboardHeader({super.key, required this.userName});

  // Stitch Design Tokens
  static const Color stitchNavy = Color(0xFF001A33);
  static const Color stitchOnSurface = Color(0xFF191C1F);
  static const Color stitchOnSurfaceVariant = Color(0xFF43474D);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherControllerProvider);
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    
    final int unreadCount = unreadCountAsync.maybeWhen(
      data: (count) => count,
      orElse: () => 0,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 0. USER MONOGRAM SEAL ──
        _buildUserAvatar(userName),
        const Gap(16),

        // ── 1. INTERACTION CANVAS: Decoupled Dual-Channel Layout ──
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── IDENTITY CHANNEL (Left) ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getGreeting(),
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: stitchOnSurfaceVariant,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      userName.split(' ')[0].toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: stitchOnSurface,
                        letterSpacing: -1.0,
                        height: 1.1,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const Gap(12), // Minimum buffer zone

              // ── HUD CHANNEL (Right) ──
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔔 TACTICAL PULSE: Only breathes when unread exists
                  unreadCount > 0
                    ? _buildNotificationBell(context, unreadCount)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                          duration: 1500.ms,
                          curve: Curves.easeInOut,
                        )
                    : _buildNotificationBell(context, unreadCount),
                  const Gap(12),
                  _buildWeatherInfo(weatherAsync),
                ],
              ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: stitchNavy,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.lexend(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context, int unreadCount) {
    final hasUnread = unreadCount > 0;
    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: hasUnread ? stitchNavy : const Color(0xFFF8FAFC),
          shape: BoxShape.circle,
          border: Border.all(
            color: hasUnread ? Colors.transparent : stitchNavy.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: hasUnread
                  ? AppTheme.errorRed.withOpacity(0.28)
                  : Colors.black.withOpacity(0.08),
              blurRadius: hasUnread ? 18 : 12,
              offset: const Offset(0, 4),
              spreadRadius: hasUnread ? 1 : 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_outlined,
              color: hasUnread ? Colors.white : stitchNavy,
              size: 26, // Scaled Up
            ),
            if (unreadCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: GoogleFonts.lexend(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(AsyncValue<WeatherData> weatherAsync) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          weatherAsync.when(
            data: (w) => _getWeatherIcon(w.weatherCode),
            loading: () => Icons.cloud_rounded,
            error: (_, __) => Icons.cloud_off_rounded,
          ),
          color: stitchNavy,
          size: 22, // Scaled Up
        ),
        const Gap(2),
        Text(
          weatherAsync.when(
            data: (w) => '${w.temperature.toStringAsFixed(0)}°C',
            loading: () => '--°C',
            error: (_, __) => '!!',
          ),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12, // Scaled Up
            fontWeight: FontWeight.w800,
            color: stitchNavy,
            height: 1,
          ),
        ),
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
