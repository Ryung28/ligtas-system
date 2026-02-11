import 'package:flutter/material.dart';
import 'package:mobileapplication/userdashboard/banperioidpage/banperiodcalender_page.dart';
import 'package:mobileapplication/userdashboard/ocean_education.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:math';
import 'package:mobileapplication/userdashboard/userdashboardpage/user_notification_bell.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/userdashboard/config/language_provider.dart';

class UserDashboardWidgets {
  static Widget navbarHeader(
    String userName,
    bool isLoading,
    Color textColor,
    Color surfaceBlue,
    Color whiteWater,
    String? userPhotoUrl,
    String currentQuote,
  ) {
    return Builder(builder: (context) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final now = DateTime.now();
      final hour = now.hour;

      // Enhanced colors for gradient background
      final Color gradientStart = isDarkMode
          ? const Color(0xFF1A75C7) // Darker blue for dark mode
          : const Color(0xFF2196F3); // Brighter blue for light mode
      final Color gradientEnd = isDarkMode
          ? const Color(0xFF0D47A1) // Deep blue for dark mode
          : const Color(0xFF1565C0); // Medium deep blue for light mode

      const Color textColorLight = Colors.white;

      // Personalized greeting based on time of day and language
      String getTimeBasedGreeting() {
        final settingsProvider =
            Provider.of<SettingsProviderV2>(context, listen: false);
        final language = settingsProvider.selectedLanguage;

        if (hour < 12) {
          switch (language) {
            case SupportedLanguage.english:
              return 'Good morning';
            case SupportedLanguage.tagalog:
              return 'Magandang umaga';
            case SupportedLanguage.cebuano:
              return 'Maayong buntag';
          }
        }
        if (hour < 17) {
          switch (language) {
            case SupportedLanguage.english:
              return 'Good afternoon';
            case SupportedLanguage.tagalog:
              return 'Magandang hapon';
            case SupportedLanguage.cebuano:
              return 'Maayong hapon';
          }
        }
        switch (language) {
          case SupportedLanguage.english:
            return 'Good evening';
          case SupportedLanguage.tagalog:
            return 'Magandang gabi';
          case SupportedLanguage.cebuano:
            return 'Maayong gabii';
        }
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
            stops: const [0.0, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: gradientStart.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Decorative background elements
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row with avatar and greeting
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Enhanced avatar with animation-ready container
                        Hero(
                          tag: 'user_avatar',
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white,
                              backgroundImage: userPhotoUrl != null &&
                                      userPhotoUrl.isNotEmpty
                                  ? NetworkImage(userPhotoUrl)
                                  : null,
                              child:
                                  userPhotoUrl == null || userPhotoUrl.isEmpty
                                      ? Icon(
                                          Icons.person_rounded,
                                          color: gradientStart,
                                          size: 32,
                                        )
                                      : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time-based greeting
                              Text(
                                getTimeBasedGreeting(),
                                style:
                                    UserDashboardFonts.bodyTextMedium.copyWith(
                                  color: textColorLight.withOpacity(0.9),
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // User name with enhanced typography
                              Text(
                                isLoading ? 'Loading...' : userName,
                                style:
                                    UserDashboardFonts.titleTextBold.copyWith(
                                  color: textColorLight,
                                  height: 1.1,
                                  fontSize: 22,
                                  letterSpacing: 0.3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Status indicator
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(
                                          0xFF4ADE80), // Green for active
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Active',
                                    style:
                                        UserDashboardFonts.smallText.copyWith(
                                      color: textColorLight.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Enhanced notification bell
                        const UserNotificationBellStyled(),
                      ],
                    ),

                    // Quick action buttons
                    const SizedBox(height: 20),
                    _buildQuickActionButtons(
                        context, isDarkMode, textColorLight),

                    // Inspirational quote section
                    if (currentQuote.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildQuoteSection(currentQuote, textColorLight),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Quick action buttons for common tasks
  static Widget _buildQuickActionButtons(
      BuildContext context, bool isDarkMode, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            context: context,
            icon: Icons.report_problem_rounded,
            label: 'Report',
            color: const Color(0xFFF87171),
            onTap: () {
              // Navigate to complaint page
              Navigator.pushNamed(context, '/complaint');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            context: context,
            icon: Icons.school_rounded,
            label: 'Learn',
            color: const Color(0xFF0A3D91), // Even more vibrant ocean blue
            onTap: () {
              // Navigate to education hub
              Navigator.pushNamed(context, '/education');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            context: context,
            icon: Icons.calendar_today_rounded,
            label: 'Schedule',
            color: const Color(0xFF0D47A1), // More vibrant ocean blue
            onTap: () {
              // Navigate to ban period calendar
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BanPeriodCalendar(isAdmin: false),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: UserDashboardFonts.smallText.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced quote section with better styling
  static Widget _buildQuoteSection(String quote, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: UserDashboardFonts.bodyTextMedium.copyWith(
                color: Colors.white.withOpacity(0.95),
                fontStyle: FontStyle.italic,
                height: 1.5,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildCompactMarineCondition(IconData icon, String value,
      String label, bool isWhite, Color deepBlue, Color whiteWater) {
    Color textColor = isWhite ? whiteWater : Colors.black87;
    const String defaultFontFamily = 'Roboto';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.black87, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            fontFamily: defaultFontFamily,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 11,
            letterSpacing: 0.2,
            fontWeight: FontWeight.w500,
            fontFamily: defaultFontFamily,
          ),
        ),
      ],
    );
  }

  static Widget buildDateInfo(
      String label, String date, Color color, bool isWhite, Color whiteWater) {
    const String defaultFontFamily = 'Roboto';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWhite ? whiteWater.withOpacity(0.1) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: defaultFontFamily,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              color: whiteWater,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: defaultFontFamily,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildEducationCard(
      String title,
      IconData icon,
      String description,
      Color surfaceBlue,
      Color accentBlue,
      Color deepBlue,
      BuildContext context) {
    const String defaultFontFamily = 'Roboto';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarineEducationPage(
              isAdmin: false,
              category: title,
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [surfaceBlue.withOpacity(0.2), accentBlue.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentBlue, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: deepBlue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: defaultFontFamily,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: deepBlue.withOpacity(0.6),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: defaultFontFamily,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildNavItem(
    IconData icon,
    String label,
    int index,
    int currentIndex,
    List<Animation<double>> animations,
    Function(int) onTap,
    Color surfaceBlue,
    Color deepBlue,
  ) {
    bool isSelected = currentIndex == index;
    const String defaultFontFamily = 'Roboto';

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 15,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? surfaceBlue.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: animations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset:
                      Offset(0, isSelected ? -4 * animations[index].value : 0),
                  child: Icon(
                    icon,
                    color: isSelected ? surfaceBlue : deepBlue.withOpacity(0.5),
                    size: isSelected ? 28 : 24,
                  ),
                );
              },
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? surfaceBlue : deepBlue.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
                fontFamily: defaultFontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildBanPeriodCard(
    DateTime? startDate,
    DateTime? endDate,
    Color surfaceBlue,
    Color accentBlue,
    Color whiteWater,
    BuildContext context, {
    String? description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsProvider =
        Provider.of<SettingsProviderV2>(context, listen: false);
    final themeColors = settingsProvider.getCurrentThemeColors(isDark);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeColors['primary']!.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColors['deepBlue']!,
            themeColors['primary']!,
          ],
          stops: const [0.3, 1.0],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative elements (smaller)
            Positioned(
              top: -15,
              right: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeColors['card']!.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -10,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeColors['card']!.withOpacity(0.03),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with title and arrow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: themeColors['card']!.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: themeColors['card']!,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ban Period Schedule',
                            style:
                                UserDashboardFonts.largeTextSemiBold.copyWith(
                              color: themeColors['card']!,
                              letterSpacing: 0.2,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BanPeriodCalendar(isAdmin: false),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: themeColors['card']!.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: themeColors['card']!.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Expand',
                                  style: TextStyle(
                                    color:
                                        themeColors['card']!.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: themeColors['card']!.withOpacity(0.9),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Date containers
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateBox(
                          isStart: true,
                          date: startDate,
                          themeColors: themeColors,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateBox(
                          isStart: false,
                          date: endDate,
                          themeColors: themeColors,
                        ),
                      ),
                    ],
                  ),
                  if (startDate != null && endDate != null) ...[
                    const SizedBox(height: 12),
                    _buildDateRangeIndicator(startDate, endDate, themeColors),
                  ],
                  // Show description if available
                  if (description != null && description.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeColors['card']!.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: themeColors['card']!.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: themeColors['card']!.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              description,
                              style: UserDashboardFonts.smallText.copyWith(
                                color: themeColors['card']!.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for date boxes
  static Widget _buildDateBox({
    required bool isStart,
    required DateTime? date,
    required Map<String, Color> themeColors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isStart
              ? const Color(0xFF4ADE80).withOpacity(0.3) // Green for start
              : const Color(0xFFF87171).withOpacity(0.3), // Red for end
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isStart
                    ? Icons.play_circle_outline_rounded
                    : Icons.stop_circle_outlined,
                color: isStart
                    ? const Color(0xFF4ADE80) // Green for start
                    : const Color(0xFFF87171), // Red for end
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isStart ? 'Start Date' : 'End Date',
                style: UserDashboardFonts.smallText.copyWith(
                  color: isStart
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFF87171),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date != null ? DateFormat('MMMM d, yyyy').format(date) : 'Not set',
            style: UserDashboardFonts.bodyTextMedium.copyWith(
              color: themeColors['card']!,
            ),
          ),
          if (date != null) ...[
            const SizedBox(height: 2),
            Text(
              DateFormat('EEEE').format(date), // Day of week
              style: UserDashboardFonts.smallText.copyWith(
                color: themeColors['card']!.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper method for date range indicator
  static Widget _buildDateRangeIndicator(
    DateTime startDate,
    DateTime endDate,
    Map<String, Color> themeColors,
  ) {
    // Calculate days remaining
    final now = DateTime.now();
    final daysTotal = endDate.difference(startDate).inDays;
    final daysRemaining = now.isAfter(startDate) && now.isBefore(endDate)
        ? endDate.difference(now).inDays
        : 0;

    // Calculate progress more accurately
    double progress = 0.0;
    int daysElapsed = 0;

    if (now.isBefore(startDate)) {
      // Ban period hasn't started yet
      progress = 0.0;
      daysElapsed = 0;
    } else if (now.isAfter(endDate)) {
      // Ban period has ended
      progress = 1.0;
      daysElapsed = daysTotal;
    } else {
      // Ban period is active
      daysElapsed =
          now.difference(startDate).inDays + 1; // +1 to include current day
      progress = daysElapsed / daysTotal;
    }

    // Check if ban period is from previous year
    final isPastYear = startDate.year < now.year;

    // Calculate optimal colors for better contrast across all themes
    final isDarkTheme = _isDarkTheme(themeColors);
    final primaryColor = themeColors['primary']!;

    // High contrast text colors that work on all themes
    final titleTextColor = isDarkTheme
        ? Colors.white.withOpacity(0.9)
        : Colors.white.withOpacity(0.9);
    final subtitleTextColor = isDarkTheme
        ? Colors.white.withOpacity(0.7)
        : Colors.white.withOpacity(0.7);
    final progressTextColor = isDarkTheme
        ? Colors.white.withOpacity(0.8)
        : Colors.white.withOpacity(0.8);

    // Dynamic progress bar colors based on theme
    final progressBarBackground = isDarkTheme
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.15);
    final progressBarBorder = isDarkTheme
        ? Colors.white.withOpacity(0.2)
        : primaryColor.withOpacity(0.2);

    // Progress fill colors that provide good contrast
    final progressFillColors = isDarkTheme
        ? [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ]
        : [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.8),
          ];

    // Progress percentage text color with dynamic contrast
    final progressPercentageColor = isDarkTheme
        ? Colors.black // Black text on white progress bar
        : Colors.black; // Black text on white progress bar

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Ban Period Progress',
                  style: UserDashboardFonts.smallText.copyWith(
                    color: titleTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isPastYear) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'PAST YEAR',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '$daysTotal days total',
              style: UserDashboardFonts.extraSmallText.copyWith(
                color: subtitleTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Modern Progress Bar with Animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.0, end: progress.clamp(0.0, 1.0)),
          builder: (context, animatedProgress, child) {
            return Column(
              children: [
                // Progress Bar Container
                Container(
                  height: 16, // Increased height to prevent text cutoff
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: progressBarBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: progressBarBorder,
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background fill
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isDarkTheme
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.05),
                        ),
                      ),
                      // Progress fill with gradient
                      FractionallySizedBox(
                        widthFactor: animatedProgress,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: progressFillColors,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkTheme
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Progress percentage text
                      Center(
                        child: Text(
                          '${(animatedProgress * 100).round()}%',
                          style: TextStyle(
                            fontSize: 11, // Slightly larger font
                            fontWeight: FontWeight.w600,
                            color: progressPercentageColor,
                            shadows: isDarkTheme
                                ? [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 1,
                                      offset: const Offset(0, 0.5),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Progress details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: UserDashboardFonts.extraSmallText.copyWith(
                        color: progressTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$daysElapsed / $daysTotal days',
                      style: UserDashboardFonts.extraSmallText.copyWith(
                        color: isDarkTheme
                            ? Colors.white.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 6),
        if (daysRemaining > 0)
          Text(
            '$daysRemaining days remaining',
            style: UserDashboardFonts.extraSmallText.copyWith(
              color: isDarkTheme
                  ? Colors.white.withOpacity(0.8)
                  : Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  // Helper method to determine if theme is dark based on color values
  static bool _isDarkTheme(Map<String, Color> themeColors) {
    final cardColor = themeColors['card']!;
    final backgroundColor = themeColors['background']!;

    // Calculate luminance to determine if theme is dark
    final cardLuminance = _calculateLuminance(cardColor);
    final backgroundLuminance = _calculateLuminance(backgroundColor);

    // If both card and background are dark, it's a dark theme
    return cardLuminance < 0.5 && backgroundLuminance < 0.5;
  }

  // Helper method to calculate color luminance
  static double _calculateLuminance(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    // Apply gamma correction
    final rLinear = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
    final gLinear = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
    final bLinear = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

    return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
  }

  static Color _getMetricColor(
      String metricType, bool isDarkMode, Color deepBlue) {
    if (isDarkMode) {
      switch (metricType) {
        case 'Waves':
          return const Color(0xFF1565C0); // Blue for waves
        case 'Wind':
          return const Color(0xFF4CAF50); // Green for wind
        case 'UV Index':
          return const Color(0xFFFF9800); // Orange for UV index
        case 'Temp':
          return const Color(0xFFFF7043); // Orange for temperature
        default:
          return const Color(0xFF1565C0); // Default blue
      }
    }

    switch (metricType) {
      case 'Waves':
        return const Color(0xFF0A3D91); // Deep blue for waves
      case 'Wind':
        return const Color(0xFF2E7D32); // Green for wind
      case 'UV Index':
        return const Color(0xFFE65100); // Dark orange for UV index
      case 'Temp':
        return const Color(0xFFFF7043); // Orange for temperature
      default:
        return const Color(0xFF0A3D91); // Default deep blue
    }
  }

  static Widget buildMarineConditionsCard(
    Map<String, dynamic> marineData,
    Color whiteWater,
    Color deepBlue,
    Color accentBlue,
    Color surfaceBlue,
    VoidCallback onRefresh,
  ) {
    const String defaultFontFamily = 'Roboto';
    return Builder(builder: (context) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      // Ensure text colors in this card provide good contrast against `whiteWater` or `ThemeConfig.darkCard`
      final Color cardTitleColor = isDarkMode ? Colors.white : deepBlue;
      final Color metricValueColor =
          isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
      final Color metricLabelColor =
          isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode
              ? ThemeConfig.darkCard
              : whiteWater, // Using ThemeConfig here
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.black : deepBlue).withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentBlue.withOpacity(0.8),
                            accentBlue.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: accentBlue.withOpacity(0.15),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: const Color(0xFF0A3D91), // Darker ocean blue
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Marine Conditions',
                      style: TextStyle(
                        color: cardTitleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                        fontFamily: defaultFontFamily,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: const Color(0xFF0A3D91), // Darker ocean blue
                    size: 16,
                  ),
                  onPressed: onRefresh,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Marine metrics in a row instead of a grid
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCompactMetric(
                    Icons.waves_rounded,
                    '${(marineData['waveHeight'] ?? 0).toStringAsFixed(2)}m',
                    'Waves',
                    const Color(0xFF0A3D91), // Darker ocean blue for waves
                    defaultFontFamily,
                    metricValueColor,
                    metricLabelColor,
                    isDarkMode,
                  ),
                  _buildVerticalDivider(isDarkMode, accentBlue),
                  _buildCompactMetric(
                    Icons.air_rounded,
                    '${marineData['windSpeed'] ?? 0}km/h',
                    'Wind',
                    const Color(0xFF1B5E20), // Darker green for wind
                    defaultFontFamily,
                    metricValueColor,
                    metricLabelColor,
                    isDarkMode,
                  ),
                  _buildVerticalDivider(isDarkMode, accentBlue),
                  _buildCompactMetric(
                    Icons.wb_sunny_rounded,
                    '${marineData['uvIndex'] ?? 0}',
                    'UV',
                    const Color(0xFFD84315), // Darker orange for UV
                    defaultFontFamily,
                    metricValueColor,
                    metricLabelColor,
                    isDarkMode,
                  ),
                  _buildVerticalDivider(isDarkMode, accentBlue),
                  _buildCompactMetric(
                    Icons.thermostat_rounded,
                    '${marineData['temperature'] ?? 0}°C',
                    'Temp',
                    const Color(0xFFE65100), // Darker orange for temperature
                    defaultFontFamily,
                    metricValueColor,
                    metricLabelColor,
                    isDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildMarineAdviceStrip(
              isDarkMode,
              accentBlue,
              defaultFontFamily,
              marineData,
            ),
          ],
        ),
      );
    });
  }

  static Widget _buildMarineAdviceStrip(
    bool isDarkMode,
    Color accentBlue,
    String fontFamily,
    Map<String, dynamic> marineData,
  ) {
    String adviceText = "Safe for sailing. Enjoy your day on the water!";
    IconData adviceIcon = Icons.check_circle_rounded;
    Color advisoryColor = Color(0xFF4ADE80); // Green

    // Logic to determine advice based on marine conditions
    if ((marineData['waveHeight'] ?? 0) > 2 ||
        (marineData['windSpeed'] ?? 0) > 25 ||
        (marineData['uvIndex'] ?? 0) > 6) {
      adviceText = "Caution advised. Conditions may be challenging.";
      adviceIcon = Icons.warning_rounded;
      advisoryColor = Color(0xFFFCD34D); // Yellow
    }

    if ((marineData['waveHeight'] ?? 0) > 3.5 ||
        (marineData['windSpeed'] ?? 0) > 35 ||
        (marineData['uvIndex'] ?? 0) > 8) {
      adviceText = "Not recommended for sailing. Please stay safe.";
      adviceIcon = Icons.dangerous_rounded;
      advisoryColor = Color(0xFFF87171); // Red
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? advisoryColor.withOpacity(0.15)
            : advisoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: advisoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            adviceIcon,
            color: advisoryColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              adviceText,
              style: TextStyle(
                color:
                    isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCompactMetric(
    IconData icon,
    String value,
    String label,
    Color accentColor,
    String fontFamily,
    Color valueColor,
    Color labelColor,
    bool isDarkMode,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: accentColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: accentColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }

  static Widget _buildVerticalDivider(bool isDarkMode, Color accentColor) {
    return Container(
      height: 30,
      width: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDarkMode ? Colors.white : accentColor).withOpacity(0.1),
            (isDarkMode ? Colors.white : accentColor).withOpacity(0.3),
            (isDarkMode ? Colors.white : accentColor).withOpacity(0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
