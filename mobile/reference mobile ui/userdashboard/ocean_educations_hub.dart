// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobileapplication/userdashboard/components/wave_animation.dart';
import 'package:mobileapplication/userdashboard/ocean_education.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/userdashboard_provider.dart';
import 'package:mobileapplication/utils/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobileapplication/providers/navigation_provider.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';
import 'package:mobileapplication/models/ocean_education_category.dart';
import 'package:mobileapplication/services/ocean_category_service.dart';

class OceanEducationHub extends StatefulWidget {
  const OceanEducationHub({super.key});

  @override
  _OceanEducationHubState createState() => _OceanEducationHubState();
}

class _OceanEducationHubState extends State<OceanEducationHub>
    with TickerProviderStateMixin {
  late AnimationController _contentFadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final OceanCategoryService _categoryService = OceanCategoryService();
  bool _showScrollToTop = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  
  // Cache categories to prevent rebuilds
  List<OceanEducationCategory> _cachedCategories = [];
  bool _categoriesLoaded = false;
  StreamSubscription<List<OceanEducationCategory>>? _categorySubscription;

  // Featured articles - now as a constant for better performance
  static const List<Map<String, dynamic>> _featuredArticles = [
    {
      'title': 'Protecting Coral Reefs',
      'image': 'assets/EducationalInfoBackground.jpg',
      'description': 'Learn how we can protect these vital ecosystems'
    },
    {
      'title': 'Marine Biodiversity',
      'image': 'assets/MarineGaurdBackground.jpg',
      'description': 'Discover the incredible diversity of ocean life'
    },
    {
      'title': 'Sustainable Fishing',
      'image': 'assets/EducationalInfoBackground.jpg',
      'description': 'Best practices for ocean conservation'
    },
  ];

  // Helper method to safely get theme colors with fallbacks
  static Map<String, Color> _getSafeThemeColors(
      Map<String, Color> themeColors) {
    return {
      'primary': themeColors['primary'] ?? const Color(0xFF1976D2),
      'deepBlue': themeColors['deepBlue'] ?? const Color(0xFF0A4FA8),
      'surfaceBlue': themeColors['surfaceBlue'] ?? const Color(0xFF4A90E2),
      'blueAccent': themeColors['blueAccent'] ?? const Color(0xFF64B5F6),
      'accentBlue': themeColors['accentBlue'] ?? const Color(0xFF0288D1),
      'card': themeColors['card'] ?? Colors.white,
      'background': themeColors['background'] ?? const Color(0xFFF5F9FF),
      'text': themeColors['text'] ?? const Color(0xFF2C3E50),
      'gradientStart': themeColors['gradientStart'] ?? const Color(0xFFF0F5FA),
      'gradientEnd': themeColors['gradientEnd'] ?? const Color(0xFFDAE7F8),
    };
  }

  // Categories are now fetched from Firestore dynamically
  // Old hardcoded method removed to use admin-managed categories

  @override
  void initState() {
    super.initState();
    _contentFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _contentFadeController, curve: Curves.easeOutCirc));

    _contentFadeController.forward();
    _scrollController.addListener(_handleScroll);

    // Listen to category stream for real-time updates
    _listenToCategories();

    // Initialize navigation provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final navigationProvider =
            Provider.of<NavigationProvider>(context, listen: false);
        navigationProvider.initialize();
      }
    });
  }

  void _listenToCategories() {
    _categorySubscription?.cancel(); // Cancel previous subscription if exists
    _categorySubscription = _categoryService.getActiveCategories().listen(
      (categories) {
        if (mounted) {
          setState(() {
            _cachedCategories = categories;
            _categoriesLoaded = true;
            debugPrint('📚 [USER] Stream update: ${categories.length} active categories');
            for (var cat in categories) {
              debugPrint('   - ${cat.title} (active: ${cat.isActive}, order: ${cat.order})');
            }
          });
        }
      },
      onError: (e) {
        debugPrint('❌ [USER] Error in category stream: $e');
        debugPrint('   Stack trace: ${StackTrace.current}');
        if (mounted) {
          setState(() {
            _categoriesLoaded = true;
            _cachedCategories = []; // Clear on error
          });
        }
      },
      cancelOnError: false, // Keep listening even on error
    );
  }

  void _handleScroll() {
    if (mounted) {
      final bool shouldShowButton = _scrollController.offset > 300;

      if (shouldShowButton != _showScrollToTop) {
        setState(() {
          _showScrollToTop = shouldShowButton;
        });
      }
    }
  }

  @override
  void dispose() {
    _categorySubscription?.cancel();
    _contentFadeController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserDashboardProvider>(context, listen: false);
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final bool isWebPlatform = kIsWeb;
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLargeScreen = screenSize.width > 1024;
    final bool isMediumScreen =
        screenSize.width > 768 && screenSize.width <= 1024;

    final settingsProvider =
        Provider.of<SettingsProviderV2>(context, listen: true);
    final rawThemeColors =
        settingsProvider.getCurrentThemeColors(!isLightTheme);
    final themeColors = _getSafeThemeColors(rawThemeColors);

    final Color primaryBlue = themeColors['primary']!;
    final Color deepNavyBlue = themeColors['deepBlue']!;
    final Color pureWhite = themeColors['card']!;
    final Color darkBackground = themeColors['background']!;

    final Color navBackgroundColor = isLightTheme
        ? pureWhite.withOpacity(0.9)
        : darkBackground.withOpacity(0.9);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          isLightTheme ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLightTheme ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: navBackgroundColor,
      systemNavigationBarIconBrightness:
          isLightTheme ? Brightness.dark : Brightness.light,
    ));

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              mini: !isWebPlatform,
              backgroundColor: primaryBlue,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutQuad,
                );
              },
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
      body: Stack(
        children: [
          // Background color using theme colors
          Container(
            height: screenSize.height,
            width: screenSize.width,
            color: themeColors['background']!,
          ),

          // Use our new wave animation component
          WaveAnimationBackground(
              isDark: !isLightTheme, screenSize: screenSize),

          // Content with fade animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildMainContent(
              isLightTheme,
              isWebPlatform,
              isLargeScreen,
              isMediumScreen,
              screenSize,
              deepNavyBlue,
              primaryBlue,
              themeColors,
            ),
          ),
        ],
      ),
    );
  }

  // Main content extracted to its own method for better organization
  Widget _buildMainContent(
    bool isLightTheme,
    bool isWebPlatform,
    bool isLargeScreen,
    bool isMediumScreen,
    Size screenSize,
    Color deepNavyBlue,
    Color primaryBlue,
    Map<String, Color> themeColors,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        _buildAppBar(isLightTheme, isWebPlatform, isLargeScreen, deepNavyBlue,
            themeColors),
        if (isWebPlatform && (isLargeScreen || isMediumScreen))
          _buildFeaturedContentSlider(),
        // Header Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isWebPlatform ? (isLargeScreen ? 50.0 : 30.0) : 16.0,
              isWebPlatform ? 30.0 : 24.0,
              isWebPlatform ? (isLargeScreen ? 50.0 : 30.0) : 16.0,
              0,
            ),
            child: _buildHeaderSection(isLightTheme, isWebPlatform),
          ),
        ),

        // Search and Filter Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isWebPlatform ? (isLargeScreen ? 50.0 : 30.0) : 16.0,
              isWebPlatform ? 30.0 : 20.0,
              isWebPlatform ? (isLargeScreen ? 50.0 : 30.0) : 16.0,
              0,
            ),
            child: _buildSearchAndFilterSection(
                isLightTheme, isWebPlatform, themeColors),
          ),
        ),

        // Education Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isWebPlatform ? (isLargeScreen ? 50.0 : 30.0) : 16.0,
              isWebPlatform ? 30.0 : 20.0,
              isWebPlatform ? (isLargeScreen ? 50.0 : 30.0) : 16.0,
              80 + MediaQuery.of(context).padding.bottom,
            ),
            child: _buildEducationSection(
                isLightTheme, isWebPlatform, isLargeScreen, themeColors),
          ),
        ),
      ],
    );
  }

  // App bar extracted to its own method
  Widget _buildAppBar(
    bool isLightTheme,
    bool isWebPlatform,
    bool isLargeScreen,
    Color deepNavyBlue,
    Map<String, Color> themeColors,
  ) {
    return SliverAppBar(
      automaticallyImplyLeading: true,
      expandedHeight: isWebPlatform ? 380.0 : 240.0,
      floating: false,
      pinned: true,
      backgroundColor: themeColors['primary']!.withOpacity(0.85),
      elevation: 4.0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
            left: isWebPlatform ? 50 : 20, bottom: 16, right: 20),
        title: Text(
          'Ocean Education Hub',
          style: UserDashboardFonts.largeHeadingText.copyWith(
            color: Colors.white,
            fontSize: isWebPlatform ? 26 : 18,
            letterSpacing: 0.3,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(1, 1),
              )
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Optimized image loading with caching parameters
            Image.asset(
              'assets/EducationalInfoBackground.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.15),
              colorBlendMode: BlendMode.darken,
              cacheHeight: isWebPlatform ? 800 : 400,
              cacheWidth: isWebPlatform ? 1600 : 800,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      themeColors['gradientStart']!.withOpacity(0.2),
                      themeColors['primary']!.withOpacity(0.6),
                      themeColors['gradientEnd']!.withOpacity(0.85),
                    ],
                    stops: const [
                      0.0,
                      0.5,
                      1.0
                    ]),
              ),
            ),
            if (isWebPlatform)
              Positioned(
                bottom: 70,
                left: 50,
                right: 50,
                child: Text(
                  'Dive deeper into ocean knowledge and conservation',
                  textAlign: TextAlign.center,
                  style: UserDashboardFonts.bodyText.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 17,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 1),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
        centerTitle: isWebPlatform ? true : false,
      ),
    );
  }

  Widget _buildFeaturedContentSlider() {
    return SliverToBoxAdapter(
      child: Container(
        height: 300,
        margin: const EdgeInsets.only(top: 24, bottom: 16),
        child: PageView.builder(
          controller: PageController(
              viewportFraction: kIsWeb ? 0.85 : 0.9, keepPage: true),
          itemCount: _featuredArticles.length,
          itemBuilder: (context, index) {
            final article = _featuredArticles[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Optimized image loading with caching
                    Image.asset(
                      article['image'],
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.1),
                      colorBlendMode: BlendMode.darken,
                      cacheHeight: 600,
                      cacheWidth: 1000,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                            stops: const [
                              0.4,
                              1.0
                            ]),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article['title'],
                              style: UserDashboardFonts.titleTextBold.copyWith(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              article['description'],
                              style: UserDashboardFonts.bodyText.copyWith(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.9),
                                    foregroundColor: const Color(0xFF073763),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Text('Read More',
                                      style: UserDashboardFonts.buttonText),
                                ),
                                const Spacer(),
                                if (kIsWeb)
                                  _buildSocialShareButtons(article['title']),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isLightTheme, bool isWebPlatform) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ocean Education Hub',
                    style: UserDashboardFonts.largeHeadingText.copyWith(
                      fontSize: isWebPlatform ? 32 : 24,
                      color: isLightTheme
                          ? const Color(0xFF073763)
                          : Colors.white.withOpacity(0.95),
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover fascinating facts and information about our oceans and marine life',
                    style: UserDashboardFonts.bodyText.copyWith(
                      fontSize: isWebPlatform ? 16 : 14,
                      color: isLightTheme
                          ? Colors.blueGrey.shade700
                          : Colors.white.withOpacity(0.75),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (isWebPlatform)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2196F3).withOpacity(0.1),
                      const Color(0xFF1976D2).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2196F3).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.book_fill,
                      color: const Color(0xFF2196F3),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '52',
                      style: UserDashboardFonts.largeTextSemiBold.copyWith(
                        fontSize: 24,
                        color: const Color(0xFF2196F3),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Total Lessons',
                      style: UserDashboardFonts.smallText.copyWith(
                        color: Colors.blueGrey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterSection(
      bool isLightTheme, bool isWebPlatform, Map<String, Color> themeColors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: themeColors['card']!,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: themeColors['primary']!.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: themeColors['primary']!.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search marine topics, facts, or keywords...',
              hintStyle: UserDashboardFonts.bodyText.copyWith(
                color: themeColors['text']!.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                CupertinoIcons.search,
                color: themeColors['primary']!,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: themeColors['text']!.withOpacity(0.6),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Category Filter - using cached categories
        if (_categoriesLoaded && _cachedCategories.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildCategoryChip('All', _selectedCategory == 'All', () {
                  setState(() {
                    _selectedCategory = 'All';
                  });
                }, themeColors),
                const SizedBox(width: 8),
                ..._cachedCategories.map((category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildCategoryChip(
                        category.title,
                        _selectedCategory == category.title,
                        () {
                          setState(() {
                            _selectedCategory = category.title;
                          });
                        },
                        themeColors,
                      ),
                    )),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChip(String title, bool isSelected, VoidCallback onTap,
      Map<String, Color> themeColors) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? themeColors['primary']!
              : themeColors['card']!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? themeColors['primary']!
                : themeColors['primary']!.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: UserDashboardFonts.smallText.copyWith(
            color: isSelected ? Colors.white : themeColors['text']!,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEducationSection(bool isLightTheme, bool isWebPlatform,
      bool isLargeScreen, Map<String, Color> themeColors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Marine Information Hub',
              style: UserDashboardFonts.largeTextSemiBold.copyWith(
                fontSize: isWebPlatform ? 24 : 20,
                color: themeColors['deepBlue']!,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isWebPlatform)
              TextButton.icon(
                onPressed: () {},
                icon: Icon(
                  CupertinoIcons.arrow_right,
                  size: 16,
                  color: themeColors['primary']!,
                ),
                label: Text(
                  'Explore All',
                  style: UserDashboardFonts.bodyText.copyWith(
                    color: themeColors['primary']!,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Use cached categories instead of StreamBuilder
        if (!_categoriesLoaded)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: CircularProgressIndicator(
                color: themeColors['primary']!,
              ),
            ),
          )
        else if (_cachedCategories.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    size: 48,
                    color: themeColors['primary']!.withOpacity(0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No categories available yet',
                    style: TextStyle(
                      color: themeColors['text']!,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please contact an administrator to set up\neducation categories.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: themeColors['text']!.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          isWebPlatform && isLargeScreen
              ? _buildEducationCardsGrid(isLightTheme, themeColors, _cachedCategories)
              : _buildEducationCardsList(isLightTheme, themeColors, _cachedCategories),
      ],
    );
  }

  List<OceanEducationCategory> _getFilteredCategories(
      List<OceanEducationCategory> categories) {
    var filtered = categories;

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((category) => category.title == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((category) {
        final title = category.title.toLowerCase();
        final subtitle = category.subtitle.toLowerCase();
        final description = category.description.toLowerCase();
        final query = _searchQuery.toLowerCase();

        return title.contains(query) ||
            subtitle.contains(query) ||
            description.contains(query);
      }).toList();
    }

    return filtered;
  }

  Widget _buildEducationCardsGrid(bool isLightTheme,
      Map<String, Color> themeColors, List<OceanEducationCategory> categories) {
    final filteredCategories = _getFilteredCategories(categories);
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 0.85,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: filteredCategories
          .map((category) => _buildEducationCardContent(
              category, isLightTheme, themeColors))
          .toList(),
    );
  }

  Widget _buildEducationCardsList(bool isLightTheme,
      Map<String, Color> themeColors, List<OceanEducationCategory> categories) {
    final filteredCategories = _getFilteredCategories(categories);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredCategories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        return _buildEducationCardContent(
          category,
          isLightTheme,
          themeColors,
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

  Widget _buildEducationCardContent(
    OceanEducationCategory category,
    bool isLightTheme,
    Map<String, Color> themeColors,
  ) {
    final Color cardBgColor = themeColors['card']!;
    final Color titleColor = themeColors['deepBlue']!;
    final Color subtitleColor =
        isLightTheme ? Colors.grey.shade600 : Colors.grey.shade400;
    final Color descriptionColor =
        isLightTheme ? Colors.grey.shade700 : Colors.grey.shade300;
    
    final categoryColor = Color(category.colorValue);
    final icon = _getIconFromName(category.iconName);
    final gradientColors = [categoryColor, categoryColor.withOpacity(0.7)];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: cardBgColor,
        border: Border.all(
          color: categoryColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            PageTransition(
              page: MarineEducationPage(
                isAdmin: false,
                category: category.title.trim(), // Ensure trimmed category name for exact matching
                categoryData: category, // Pass full category object for fallback content
              ),
              transitionType: TransitionType.scale,
              alignment: Alignment.center,
              curve: Curves.fastOutSlowIn,
              duration: const Duration(milliseconds: 450),
            ),
          ),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and category badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),

                const SizedBox(height: 20),

                // Title and subtitle
                Text(
                  category.title,
                  style: UserDashboardFonts.largeTextSemiBold.copyWith(
                    fontSize: kIsWeb ? 22 : 20,
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  category.subtitle,
                  style: UserDashboardFonts.bodyText.copyWith(
                    fontSize: kIsWeb ? 15 : 14,
                    color: subtitleColor,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UserDashboardFonts.smallText.copyWith(
                    fontSize: kIsWeb ? 13 : 12,
                    color: descriptionColor,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                // Footer - Explore button
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explore',
                            style: UserDashboardFonts.smallText.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            CupertinoIcons.arrow_right_circle_fill,
                            color: categoryColor,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialShareButtons(String content) {
    Future<void> shareToSocialMedia(String platform) async {
      String pageUrl =
          'https://marineguard.app/education/${Uri.encodeComponent(content)}';
      String shareText = Uri.encodeComponent(
          'Check out "$content" on Marine Guard Education Hub! $pageUrl #OceanConservation #MarineGuardApp');
      String url = '';

      switch (platform) {
        case 'twitter':
          url = 'https://twitter.com/intent/tweet?text=$shareText';
          break;
        case 'facebook':
          url =
              'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(pageUrl)}&quote=$shareText';
          break;
        case 'copy':
          await Clipboard.setData(ClipboardData(text: pageUrl));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Link to "$content" copied!',
                  style: UserDashboardFonts.bodyText),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF073763),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(10),
            ));
          }
          return;
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $platform.')),
          );
        }
      }
    }

    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color iconColor =
        isLightTheme ? Colors.blueGrey.shade600 : Colors.blueGrey.shade300;
    final Color buttonBgColor = isLightTheme
        ? Colors.white.withOpacity(0.7)
        : const Color(0xFF2C3A47).withOpacity(0.8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSocialButton(buttonBgColor, CupertinoIcons.link, iconColor,
            () => shareToSocialMedia('copy')),
        const SizedBox(width: 8),
        _buildSocialButton(
            const Color(0xFF1DA1F2),
            const IconData(0xf099, fontFamily: 'FontAwesomeBrands'),
            Colors.white,
            () => shareToSocialMedia('twitter')),
        const SizedBox(width: 8),
        _buildSocialButton(
            const Color(0xFF1877F2),
            const IconData(0xf39e, fontFamily: 'FontAwesomeBrands'),
            Colors.white,
            () => shareToSocialMedia('facebook')),
      ],
    );
  }

  Widget _buildSocialButton(
    Color backgroundColor,
    IconData icon,
    Color iconColor,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 14, color: iconColor),
        onPressed: onPressed,
        splashRadius: 15,
      ),
    );
  }
}
