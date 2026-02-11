import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
import 'package:mobileapplication/providers/theme_provider.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';

// Admin Bottom Navigation Bar Widget - Copied from User Navbar
class AdminBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Color backgroundColor;
  final void Function(int) onItemTapped;

  const AdminBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.backgroundColor,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  State<AdminBottomNavBar> createState() => _AdminBottomNavBarState();
}

class _AdminBottomNavBarState extends State<AdminBottomNavBar>
    with SingleTickerProviderStateMixin {
  // Page configurations for Admin
  late final List<NavItemConfig> _navItems;

  @override
  void initState() {
    super.initState();
    _initializeAdminNavigation();
  }

  // Admin Navigation Configuration
  void _initializeAdminNavigation() {
    _navItems = [
      NavItemConfig(Icons.dashboard_rounded, 'Dashboard'),
      NavItemConfig(Icons.people_rounded, 'Users'),
      NavItemConfig(Icons.assessment_rounded, 'Reports'),
      NavItemConfig(Icons.school_rounded, 'Education'),
    ];
  }

  void _handleNavigation(int index) {
    if (index == widget.currentIndex) return;
    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: AdminBottomNavBar building - NEW ADMIN FILE IS BEING USED!');

    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider =
        Provider.of<SettingsProviderV2>(context, listen: true);
    final isDark = themeProvider.isDarkMode;
    final themeColors = settingsProvider.getCurrentThemeColors(isDark);

    final selectedColor =
        isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
    final unselectedColor =
        isDark ? Colors.white70 : themeColors['text']!.withOpacity(0.6);

    // EXACT COPY of User Navbar - but always visible for admin (no toggle)
    return Container(
      color:
          Colors.red, // TEMP: Add red background to test if new widget is used
      child: SizedBox(
        height: 80,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Main Navigation Bar - Always visible for admin (same as user when visible)
            Positioned(
              bottom: 40, // Same position as user when visible
              left: 16,
              right: 16,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors
                      .blue, // TEMP: Blue color to test if new widget is used
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: selectedColor.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0,
                        selectedColor, unselectedColor),
                    _buildNavItem(Icons.people_rounded, 'Users', 1,
                        selectedColor, unselectedColor),
                    _buildNavItem(Icons.assessment_rounded, 'Reports', 2,
                        selectedColor, unselectedColor),
                    _buildNavItem(Icons.school_rounded, 'Education', 3,
                        selectedColor, unselectedColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // EXACT COPY of User's _buildNavItem method
  Widget _buildNavItem(IconData icon, String label, int index,
      Color selectedColor, Color unselectedColor) {
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNavigation(index),
          borderRadius: BorderRadius.circular(20),
          splashColor: selectedColor.withOpacity(0.1),
          highlightColor: selectedColor.withOpacity(0.05),
          child: Container(
            // Increased padding for better touch area
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            // Ensure minimum touch target size (48x48 pixels)
            constraints: const BoxConstraints(
              minHeight: 48,
              minWidth: 48,
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0.0,
                end: isSelected ? 1.0 : 0.0,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1.0 + (0.05 * value),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color:
                            Color.lerp(unselectedColor, selectedColor, value),
                        size: 20, // Reduced size to prevent overflow
                      ),
                      const SizedBox(height: 1), // Reduced spacing
                      Text(
                        label,
                        style: UserDashboardFonts.navigationText.copyWith(
                          color:
                              Color.lerp(unselectedColor, selectedColor, value),
                          fontWeight: FontWeight.lerp(
                            FontWeight.w400,
                            FontWeight.w600,
                            value,
                          ),
                          fontSize: 9, // Reduced font size to prevent overflow
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Helper class for navigation item configuration
class NavItemConfig {
  final IconData icon;
  final String label;

  NavItemConfig(this.icon, this.label);
}
