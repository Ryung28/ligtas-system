import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobileapplication/userdashboard/ocean_educations_hub.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/reusable_userdashboard.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/animated_welcome_form.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/userdashboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:mobileapplication/providers/navigation_provider.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';
import 'package:mobileapplication/services/ocean_category_service.dart';
import 'package:mobileapplication/models/ocean_education_category.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize the provider once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider =
            Provider.of<UserDashboardProvider>(context, listen: false);
        provider.setAnimationController(_animationController);
        provider.initializeData();

        // Initialize navigation provider
        final navigationProvider =
            Provider.of<NavigationProvider>(context, listen: false);
        navigationProvider.initialize(); // Initialize the provider
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh(UserDashboardProvider provider) async {
    await provider.loadUserData();
    await provider.updateMarineData();
    await provider.loadBanPeriodData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserDashboardProvider, SettingsProviderV2>(
      builder: (context, provider, settingsProvider, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark, // Dark (black) icons
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            extendBody: true,
            backgroundColor: Colors.white, // White background
            body: Stack(
              children: [
                _buildBackground(context),
                SafeArea(
                  bottom: false, // Allow content to go behind nav bar
                  child: RefreshIndicator(
                    onRefresh: () => _handleRefresh(provider),
                    color: Colors.white, // Match refresh indicator to nav theme
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        return false; // Don't stop notification propagation
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedWelcomeForm(
                                userName: provider.userName,
                                isLoading: provider.isLoading,
                                userPhotoUrl: provider.userPhotoUrl,
                                currentQuote: provider.currentQuote,
                              ),
                              const SizedBox(height: 6),
                              _buildBanPeriodSection(context, provider),
                              const SizedBox(height: 6),
                              _buildMarineConditionsSection(context, provider),
                              const SizedBox(height: 6),
                              _buildEducationHubSection(context, provider),
                              // Add bottom padding to ensure content doesn't get hidden by bottom nav
                              SizedBox(
                                  height: 70 +
                                      MediaQuery.of(context)
                                          .padding
                                          .bottom), // Reduced padding for compact design
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackground(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final settingsProvider =
        Provider.of<SettingsProviderV2>(context, listen: true);
    final themeColors = settingsProvider.getCurrentThemeColors(isDarkMode);

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  const Color(0xFF1A237E), // Deep blue for dark mode
                  const Color(0xFF0D47A1), // Blue for dark mode
                ]
              : [
                  Colors.white, // Clean white at top
                  const Color(0xFFE3F2FD), // Light blue at bottom
                ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Stack(
        children: [
          if (!isDarkMode) ...[
            Positioned(
              top: -120,
              right: -180,
              child: Container(
                height: 400,
                width: 400,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      themeColors['blueAccent']!.withOpacity(0.25),
                      themeColors['blueAccent']!.withOpacity(0),
                    ],
                    stops: const [0.0, 0.75],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.05,
              left: -150,
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      themeColors['surfaceBlue']!.withOpacity(0.25),
                      themeColors['surfaceBlue']!.withOpacity(0),
                    ],
                    stops: const [0.0, 0.75],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.025,
                child: Image.asset(
                  'assets/MarineGaurdBackground.jpg',
                  fit: BoxFit.cover,
                  color: themeColors['primary'],
                  colorBlendMode: BlendMode.color,
                ),
              ),
            ),
          ],
          if (isDarkMode) ...[
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      themeColors['primary']!.withOpacity(0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      themeColors['accent']!.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBanPeriodSection(
      BuildContext context, UserDashboardProvider provider) {
    final settingsProvider =
        Provider.of<SettingsProviderV2>(context, listen: true);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColors = settingsProvider.getCurrentThemeColors(isDark);

    return UserDashboardWidgets.buildBanPeriodCard(
      provider.startDate,
      provider.endDate,
      themeColors['surfaceBlue']!,
      themeColors['blueAccent']!,
      themeColors['card']!,
      context,
      description: provider.banPeriodDescription,
    );
  }

  Widget _buildMarineConditionsSection(
      BuildContext context, UserDashboardProvider provider) {
    final settingsProvider =
        Provider.of<SettingsProviderV2>(context, listen: true);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColors = settingsProvider.getCurrentThemeColors(isDark);

    return UserDashboardWidgets.buildMarineConditionsCard(
      provider.marineData,
      themeColors['card']!,
      themeColors['blueAccent']!,
      themeColors['blueAccent']!,
      themeColors['text']!,
      () => provider.updateMarineData(),
    );
  }

  Widget _buildEducationHubSection(
      BuildContext context, UserDashboardProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsProvider =
        Provider.of<SettingsProviderV2>(context, listen: true);
    final themeColors = settingsProvider.getCurrentThemeColors(isDark);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeColors['card']!,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeColors['primary']!.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEducationHubHeader(context, provider),
          const SizedBox(height: 8),
          _buildEducationCards(),
        ],
      ),
    );
  }

  Widget _buildEducationHubHeader(
      BuildContext context, UserDashboardProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsProvider =
        Provider.of<SettingsProviderV2>(context, listen: true);
    final themeColors = settingsProvider.getCurrentThemeColors(isDark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: themeColors['blueAccent']!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: themeColors['primary']!,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ocean Education Hub',
                      style: UserDashboardFonts.largeTextSemiBold.copyWith(
                        color: themeColors['text']!,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Discover marine knowledge',
                      style: UserDashboardFonts.smallText.copyWith(
                        color: themeColors['text']!.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEducationCards() {
    final categoryService = OceanCategoryService();
    
    return StreamBuilder<List<OceanEducationCategory>>(
      stream: categoryService.getActiveCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text('Error loading categories'),
            ),
          );
        }
        
        final categories = snapshot.data ?? [];
        
        if (categories.isEmpty) {
          return const SizedBox.shrink(); // Hide section if no categories
        }
        
    return SizedBox(
          height: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
              children: categories.map((category) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: categories.indexOf(category) < categories.length - 1 ? 8 : 0,
                  ),
                  child: _buildModernEducationCardFromCategory(category),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'sparkles':
        return CupertinoIcons.sparkles;
      case 'shield_lefthalf_fill':
        return CupertinoIcons.shield_lefthalf_fill;
      case 'doc_text_search':
        return CupertinoIcons.doc_text_search;
      case 'exclamationmark_triangle':
        return CupertinoIcons.exclamationmark_triangle;
      case 'device_desktop':
        return CupertinoIcons.device_desktop;
      case 'search_circle':
        return CupertinoIcons.search_circle;
      case 'water':
        return Icons.water_drop;
      case 'leaf':
        return Icons.eco;
      case 'boat':
        return Icons.sailing;
      case 'anchor':
        return Icons.anchor;
      default:
        return CupertinoIcons.sparkles;
    }
  }

  Widget _buildModernEducationCardFromCategory(OceanEducationCategory category) {
    final categoryColor = Color(category.colorValue);
    final icon = _getIconFromName(category.iconName);
    final gradientColors = [categoryColor, categoryColor.withOpacity(0.7)];
    
    return Consumer2<UserDashboardProvider, SettingsProviderV2>(
      builder: (context, provider, settingsProvider, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final themeColors = settingsProvider.getCurrentThemeColors(isDark);

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OceanEducationHub(),
              ),
            );
          },
          child: Container(
            width: 160,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: themeColors['card']!,
              border: Border.all(
                color: categoryColor.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            categoryColor.withOpacity(0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: gradientColors,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: categoryColor.withOpacity(0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                icon,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                          ],
            ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: Text(
                            category.title,
                            style: UserDashboardFonts.titleTextBold.copyWith(
                              color: themeColors['text']!,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            category.subtitle,
                            style: UserDashboardFonts.bodyTextMedium.copyWith(
                              color: themeColors['text']!.withOpacity(0.6),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
            ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            category.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: UserDashboardFonts.smallText.copyWith(
                              color: themeColors['text']!.withOpacity(0.5),
                              fontSize: 8,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: categoryColor,
                                size: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
          ),
        );
      },
    );
  }

  Widget _buildModernEducationCard(
    String title,
    IconData icon,
    String subtitle,
    String description,
    Color categoryColor,
    List<Color> gradientColors,
    int lessons,
    String duration,
  ) {
    return Consumer2<UserDashboardProvider, SettingsProviderV2>(
      builder: (context, provider, settingsProvider, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final themeColors = settingsProvider.getCurrentThemeColors(isDark);

        return GestureDetector(
          onTap: () async {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OceanEducationHub(),
              ),
            );
          },
          child: Container(
            width: 160, // More compact width
            height: 180, // More compact height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: themeColors['card']!,
              border: Border.all(
                color: categoryColor.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Background gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            categoryColor.withOpacity(0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with icon and lesson count
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: gradientColors,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: categoryColor.withOpacity(0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                icon,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: categoryColor.withOpacity(0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                '$lessons',
                                style: UserDashboardFonts.smallText.copyWith(
                                  color: categoryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          title,
                          style: UserDashboardFonts.titleTextBold.copyWith(
                            color: themeColors['text']!,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Subtitle
                        Text(
                          subtitle,
                          style: UserDashboardFonts.bodyTextMedium.copyWith(
                            color: themeColors['text']!.withOpacity(0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Description
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: UserDashboardFonts.smallText.copyWith(
                            color: themeColors['text']!.withOpacity(0.5),
                            fontSize: 9,
                            height: 1.3,
                          ),
                        ),
                        const Spacer(),
                        // Footer with duration and arrow
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              duration,
                              style: UserDashboardFonts.smallText.copyWith(
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: categoryColor,
                                size: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEducationCard(String title, IconData icon, String description) {
    return Consumer2<UserDashboardProvider, SettingsProviderV2>(
      builder: (context, provider, settingsProvider, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final themeColors = settingsProvider.getCurrentThemeColors(isDark);

        return UserDashboardWidgets.buildEducationCard(
            title,
            icon,
            description,
            themeColors['surfaceBlue']!,
            themeColors['blueAccent']!,
            themeColors['primary']!,
            context);
      },
    );
  }
}
