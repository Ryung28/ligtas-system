import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/providers/navigation_provider.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
import 'package:mobileapplication/providers/theme_provider.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';
import 'admin_bottom_nav_bar.dart';

// Base Navigation Bar Widget
abstract class BaseNavBar extends StatefulWidget {
  final int currentIndex;
  final bool isAdmin;
  final Color backgroundColor;
  final void Function(int) onItemTapped;

  const BaseNavBar({
    Key? key,
    required this.currentIndex,
    required this.isAdmin,
    required this.backgroundColor,
    required this.onItemTapped,
  }) : super(key: key);
}

// Main Navigation Bar Widget
class FloatingNavBar extends BaseNavBar {
  const FloatingNavBar({
    Key? key,
    required int currentIndex,
    required Color backgroundColor,
    required void Function(int) onItemTapped,
    bool isAdmin = false,
  }) : super(
          key: key,
          currentIndex: currentIndex,
          isAdmin: isAdmin,
          backgroundColor: backgroundColor,
          onItemTapped: onItemTapped,
        );

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar>
    with SingleTickerProviderStateMixin {
  // late AnimationController _animationController;
  // late Animation<double> _fadeAnimation;
  // late Animation<Offset> _slideAnimation;

  // Page configurations for User and Admin
  // late final List<Widget> _pages;
  late final List<NavItemConfig> _navItems;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();

    // Ensure navbar is always visible when initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider =
            Provider.of<NavigationProvider>(context, listen: false);
        provider.initialize(); // Initialize the provider
      }
    });
  }

  void _initializeNavigation() {
    if (widget.isAdmin) {
      _initializeAdminNavigation();
    } else {
      _initializeUserNavigation();
    }
  }

  // User Navigation Configuration
  void _initializeUserNavigation() {
    // _pages = const [
    //   UserDashboard(),
    //   OceanEducationHub(),
    //   ComplaintPage(),
    //   UsersettingsPage(),
    // ];

    _navItems = [
      NavItemConfig(Icons.home_rounded, 'Home'),
      NavItemConfig(Icons.school_rounded, 'Education'),
      NavItemConfig(Icons.warning_rounded, 'Report'),
      NavItemConfig(Icons.settings_rounded, 'Settings'),
    ];
  }

  // Admin Navigation Configuration
  void _initializeAdminNavigation() {
    // _pages = const [
    //   AdmindashboardPage(),
    //   ManageUserPage(),
    //   // ManageReportPage(),
    //   OceanEducationHub(),
    // ];

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
  void dispose() {
    // _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NavigationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider =
        Provider.of<SettingsProviderV2>(context, listen: true);
    final isDark = themeProvider.isDarkMode;
    final themeColors = settingsProvider.getCurrentThemeColors(isDark);

    // Listen to provider.isVisible and control the animation
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     if (provider.isVisible &&
    //         _animationController.status != AnimationStatus.completed &&
    //         _animationController.status != AnimationStatus.forward) {
    //       _animationController.forward();
    //     } else if (!provider.isVisible &&
    //         _animationController.status != AnimationStatus.dismissed &&
    //         _animationController.status != AnimationStatus.reverse) {
    //       _animationController.reverse();
    //     }
    //   }
    // });

    final selectedColor = widget.isAdmin
        ? (isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32))
        : themeColors['primary']!;
    final unselectedColor =
        isDark ? Colors.white70 : themeColors['text']!.withOpacity(0.6);

    // Admin mode - use copied user navbar file
    if (widget.isAdmin) {
      print(
          'DEBUG: FloatingNavBar - Admin mode detected, using AdminBottomNavBar');
      return AdminBottomNavBar(
        currentIndex: widget.currentIndex,
        backgroundColor: widget.backgroundColor,
        onItemTapped: widget.onItemTapped,
      );
    }

    // SIMPLIFIED APPROACH: Use Stack with proper positioning for toggle functionality (User mode)
    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Main Navigation Bar - Show/hide based on provider state
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: provider.isVisible
                ? 40
                : -60, // Animate up instead of hiding completely
            left: 16,
            right: 16,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
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
                  _buildNavItem(Icons.home_rounded, 'Home', 0, selectedColor,
                      unselectedColor),
                  _buildNavItem(Icons.school_rounded, 'Education', 1,
                      selectedColor, unselectedColor),
                  const SizedBox(width: 40),
                  _buildNavItem(Icons.warning_rounded, 'Report', 2,
                      selectedColor, unselectedColor),
                  _buildNavItem(Icons.settings_rounded, 'Settings', 3,
                      selectedColor, unselectedColor),
                ],
              ),
            ),
          ),

          // Toggle Button (Centered) - Always visible
          Positioned(
            bottom: provider.isVisible
                ? 60
                : 5, // Adjust position based on navbar visibility
            child: GestureDetector(
              onTap: () => provider.isVisible
                  ? provider.hideNavbar()
                  : provider.showNavbar(),
              child: Container(
                // Increased size for better touch area
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      selectedColor,
                      selectedColor.withBlue(min(selectedColor.blue + 30, 255)),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: selectedColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  provider.isVisible
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: Colors.white,
                  size: 28, // Larger icon for better visibility
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

// Theme configurations
class NavBarTheme {
  static Color getSelectedColor(bool isDarkMode, bool isAdmin) {
    if (isAdmin) {
      return isDarkMode ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
    }
    return isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF1E88E5);
  }

  static Color getUnselectedColor(bool isDarkMode) {
    return isDarkMode ? Colors.white70 : const Color(0xFF90A4AE);
  }
}
