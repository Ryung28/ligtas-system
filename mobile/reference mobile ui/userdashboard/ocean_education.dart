import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:mobileapplication/userdashboard/formatted_content_provider.dart';
import 'package:mobileapplication/userdashboard/ocean_education_repository.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';
import 'package:mobileapplication/models/ocean_education_category.dart';
import 'package:provider/provider.dart';

class MarineEducationPage extends StatefulWidget {
  final bool isAdmin;
  final String category;
  final OceanEducationCategory? categoryData; // Optional category object for fallback content

  const MarineEducationPage({
    super.key,
    this.isAdmin = false,
    required this.category,
    this.categoryData,
  });

  @override
  _MarineEducationPageState createState() => _MarineEducationPageState();
}

class _MarineEducationPageState extends State<MarineEducationPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _contentFadeController;
  late Animation<double> _fadeAnimation;
  bool _isEditing = false;
  bool _isLoading = true;

  // Dynamic facts
  String _currentFact = '';

  // Repository for data access
  final OceanEducationRepository _repository = OceanEducationRepository();
  // Provider for formatted content
  final FormattedContentProvider _contentProvider = FormattedContentProvider();

  // Theme colors will be set in build method

  @override
  void initState() {
    super.initState();
    _contentFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _contentFadeController, curve: Curves.easeInOutCubic));

    // Start loading immediately
    _loadContent();

    // Initialize dynamic facts
    _currentFact = getDidYouKnowFact(widget.category);
  }

  @override
  void dispose() {
    _contentFadeController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    // Ensure isLoading is true at the beginning of a load operation
    if (mounted && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Get content from repository
      // Log the category being queried for debugging
      debugPrint('📚 [USER] Loading content for category: "${widget.category}"');
      final data = await _repository.getContentByCategory(widget.category);

      if (mounted) {
        if (data != null) {
          debugPrint('✅ [USER] Successfully loaded content for category "${widget.category}"');
          debugPrint('   Title: "${data['title']}"');
          setState(() {
            _titleController.text = data['title'] ?? '';
            _contentController.text = data['content'] ?? '';
            _isLoading = false;
          });
        } else {
          // No Firestore content found - use category's own data if available
          debugPrint('⚠️ [USER] No Firestore content found for category "${widget.category}"');
          debugPrint('   categoryData provided: ${widget.categoryData != null}');
          
          // CRITICAL: If categoryData exists, NEVER use hardcoded defaults
          // Always use the category's own data, even if it's minimal
          if (widget.categoryData != null) {
            final cat = widget.categoryData!;
            debugPrint('✅ [USER] Using category data:');
            debugPrint('   Title: "${cat.title}"');
            debugPrint('   Subtitle: "${cat.subtitle}"');
            debugPrint('   Description: "${cat.description}"');
            
            // Use the category's own title (trimmed)
            final title = cat.title.trim();
            
            // Build content from subtitle and description (both trimmed)
            final subtitle = cat.subtitle.trim();
            final description = cat.description.trim();
            
            // Combine subtitle and description
            String content = '';
            if (subtitle.isNotEmpty && description.isNotEmpty) {
              // Both exist - combine them
              content = '$subtitle\n\n$description';
            } else if (subtitle.isNotEmpty) {
              // Only subtitle exists
              content = subtitle;
            } else if (description.isNotEmpty) {
              // Only description exists
              content = description;
            } else {
              // Both are empty - show a helpful message
              content = 'Content for this category is being prepared. Please check back soon!';
            }
            
            debugPrint('   Final title: "$title"');
            debugPrint('   Final content: "${content.substring(0, content.length > 50 ? 50 : content.length)}..."');
            
            setState(() {
              _titleController.text = title.isNotEmpty ? title : widget.category;
              _contentController.text = content;
              _isLoading = false;
            });
          } else {
            // categoryData is null - this should only happen in edge cases
            // Show a message indicating no content is available
            debugPrint('❌ [USER] categoryData is NULL - this should not happen when navigating from category cards');
            debugPrint('   Showing empty state message');
            
            setState(() {
              _titleController.text = widget.category;
              _contentController.text = 'Content for this category is being prepared. Please check back soon!';
              _isLoading = false;
            });
          }
        }

        _contentFadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading content: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveContent() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (mounted) setState(() => _isLoading = true);

        // Use repository to save content
        await _repository.saveContent(
          category: widget.category,
          title: _titleController.text,
          content: _contentController.text,
        );

        // Clear the formatted content cache for this category
        _contentProvider.clearCache(widget.category);

        if (mounted) {
          setState(() {
            _isEditing = false;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Content saved successfully'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving content: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _toggleEdit() {
    if (mounted) {
      setState(() {
        _isEditing = !_isEditing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final bool isWebPlatform = kIsWeb;
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLargeScreen = screenSize.width > 1024;

    final settingsProvider =
        Provider.of<SettingsProviderV2>(context, listen: true);
    final themeColors = settingsProvider.getCurrentThemeColors(!isLightTheme);

    // Theme-based colors
    final Color primaryBlue = themeColors['primary']!;
    final Color accentTeal = themeColors['blueAccent']!;

    // Wave colors using theme colors
    final Color waveColor = themeColors['blueAccent']!.withOpacity(0.3);
    final Color secondaryWaveColor = themeColors['primary']!.withOpacity(0.2);

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
      backgroundColor: Colors.white,
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              heroTag: 'editSaveFab',
              backgroundColor: _isEditing ? accentTeal : primaryBlue,
              onPressed: _isEditing ? _saveContent : _toggleEdit,
              icon: Icon(
                  _isEditing ? Icons.save_alt_rounded : Icons.edit_note_rounded,
                  color: themeColors['card']!),
              label: Text(_isEditing ? 'Save Changes' : 'Edit Content',
                  style: UserDashboardFonts.buttonText
                      .copyWith(color: themeColors['card']!)),
            )
          : null,
      body: Stack(
        children: [
          Container(
            height: screenSize.height,
            width: screenSize.width,
            color: themeColors['background']!,
          ),
          CustomPaint(
            painter: StaticWavePainter(
              isDark: !isLightTheme,
              primaryColor: waveColor,
              secondaryColor: secondaryWaveColor,
            ),
            size: Size(screenSize.width, screenSize.height),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  )
                : CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverAppBar(
                        expandedHeight: isWebPlatform
                            ? (isLargeScreen ? 380.0 : 320.0)
                            : 280.0,
                        floating: false,
                        pinned: true,
                        backgroundColor:
                            themeColors['deepBlue']!.withOpacity(0.85),
                        elevation: 4.0,
                        leading: IconButton(
                          icon: Icon(CupertinoIcons.chevron_left,
                              color: themeColors['card']!, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                        actions: [
                          if (kIsWeb)
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: _buildSocialShareButtons(
                                  _titleController.text.isNotEmpty
                                      ? _titleController.text
                                      : widget.category),
                            )
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          titlePadding: EdgeInsets.only(
                              left: isWebPlatform
                                  ? (isLargeScreen ? 70 : 50)
                                  : 20,
                              bottom: 16,
                              right: isWebPlatform
                                  ? (isLargeScreen ? 70 : 50)
                                  : 20),
                          title: Text(
                            widget.category,
                            style: UserDashboardFonts.largeHeadingText.copyWith(
                                color: themeColors['card']!,
                                fontSize: isWebPlatform
                                    ? (isLargeScreen ? 26 : 22)
                                    : 18,
                                shadows: [
                                  Shadow(
                                      blurRadius: 4.0,
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(1, 1))
                                ]),
                          ),
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/EducationalInfoBackground.jpg',
                                fit: BoxFit.cover,
                                color: Colors.black.withOpacity(0.15),
                                colorBlendMode: BlendMode.darken,
                                cacheHeight: isWebPlatform ? 800 : 500,
                                cacheWidth: isWebPlatform ? 1600 : 800,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      themeColors['deepBlue']!.withOpacity(0.2),
                                      themeColors['deepBlue']!.withOpacity(0.6),
                                      themeColors['deepBlue']!
                                          .withOpacity(0.85),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                              Center(
                                child: Icon(
                                  getIconForCategory(widget.category),
                                  color: themeColors['card']!.withOpacity(0.3),
                                  size: isWebPlatform ? 120 : 100,
                                ),
                              ),
                            ],
                          ),
                          centerTitle: true,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                isWebPlatform
                                    ? (isLargeScreen ? 60.0 : 40.0)
                                    : 20.0,
                                isWebPlatform ? 30.0 : 24.0,
                                isWebPlatform
                                    ? (isLargeScreen ? 60.0 : 40.0)
                                    : 20.0,
                                (isWebPlatform
                                        ? 40
                                        : (kBottomNavigationBarHeight +
                                            (widget.isAdmin ? 80 : 20))) +
                                    MediaQuery.of(context).padding.bottom),
                            child: isWebPlatform && isLargeScreen
                                ? _buildWebLayout(isLightTheme, themeColors)
                                : _buildMobileLayout(isLightTheme, themeColors),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildWebLayout(bool isLightTheme, Map<String, Color> themeColors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(24),
            shadowColor: Colors.black.withOpacity(0.1),
            color:
                isLightTheme ? themeColors['card']! : themeColors['surface']!,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditing && widget.isAdmin) ...[
                    _buildEditableTitle(isLightTheme, themeColors),
                    const SizedBox(height: 24),
                    _buildEditableContent(isLightTheme, themeColors),
                  ] else ...[
                    if (_titleController.text.isNotEmpty) ...[
                      Text(
                        _titleController.text,
                        style:
                            UserDashboardFonts.extraLargeHeadingText.copyWith(
                          color: isLightTheme
                              ? themeColors['deepBlue']!
                              : themeColors['card']!,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _contentProvider.getFormattedContent(
                        category: widget.category,
                        content: _contentController.text,
                        isLightTheme: isLightTheme,
                      ),
                    )
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildInfoCard(isLightTheme, widget.category, themeColors),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isLightTheme, Map<String, Color> themeColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditableTitle(isLightTheme, themeColors),
        const SizedBox(height: 24),
        // Show TextField only when editing, formatted content only when viewing
        if (_isEditing) ...[
          _buildEditableContent(isLightTheme, themeColors),
          const SizedBox(height: 32),
        ] else ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _contentProvider.getFormattedContent(
              category: widget.category,
              content: _contentController.text,
              isLightTheme: isLightTheme,
            ),
          ),
          const SizedBox(height: 32),
        ],
        _buildInfoCard(isLightTheme, widget.category, themeColors),
        if (!kIsWeb) ...[
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.center,
            child: _buildSocialShareButtons(_titleController.text.isNotEmpty
                ? _titleController.text
                : widget.category),
          ),
        ],
      ],
    );
  }

  Widget _buildEditableTitle(
      bool isLightTheme, Map<String, Color> themeColors) {
    final Color fieldFillColor = isLightTheme
        ? themeColors['surface']!.withOpacity(0.7)
        : themeColors['surface']!.withOpacity(0.8);
    final Color fieldBorderColor =
        isLightTheme ? Colors.grey.shade300 : Colors.grey.shade700;
    final Color textColor =
        isLightTheme ? themeColors['deepBlue']! : themeColors['card']!;

    return TextFormField(
      controller: _titleController,
      enabled: _isEditing,
      style: UserDashboardFonts.titleTextBold.copyWith(
        color: textColor.withOpacity(_isEditing ? 1.0 : 0.9),
      ),
      decoration: InputDecoration(
        hintText: 'Enter Title Here',
        hintStyle: UserDashboardFonts.bodyText.copyWith(
          color: textColor.withOpacity(0.5),
        ),
        border: _isEditing
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
              )
            : InputBorder.none,
        enabledBorder: _isEditing
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
              )
            : InputBorder.none,
        focusedBorder: _isEditing
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: themeColors['primary']!, width: 2),
              )
            : InputBorder.none,
        filled: _isEditing,
        fillColor: _isEditing ? fieldFillColor : Colors.transparent,
        contentPadding: _isEditing
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
            : EdgeInsets.zero,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Title cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildEditableContent(
      bool isLightTheme, Map<String, Color> themeColors) {
    final Color fieldFillColor = isLightTheme
        ? themeColors['surface']!.withOpacity(0.7)
        : themeColors['surface']!.withOpacity(0.8);
    final Color fieldBorderColor =
        isLightTheme ? Colors.grey.shade300 : Colors.grey.shade700;
    final Color textColor =
        isLightTheme ? themeColors['deepBlue']! : themeColors['card']!;

    return TextFormField(
      controller: _contentController,
      enabled: _isEditing,
      maxLines: kIsWeb ? 20 : 10,
      style: UserDashboardFonts.bodyText.copyWith(
        height: 1.6,
        color: textColor.withOpacity(_isEditing ? 1.0 : 0.85),
      ),
      decoration: InputDecoration(
        hintText: 'Enter Content Here (use # for headings, - for bullets)',
        hintStyle: UserDashboardFonts.bodyText.copyWith(
          color: textColor.withOpacity(0.5),
        ),
        border: _isEditing
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
              )
            : InputBorder.none,
        enabledBorder: _isEditing
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
              )
            : InputBorder.none,
        focusedBorder: _isEditing
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: themeColors['primary']!, width: 2),
              )
            : InputBorder.none,
        filled: _isEditing,
        fillColor: _isEditing ? fieldFillColor : Colors.transparent,
        contentPadding: _isEditing ? const EdgeInsets.all(16) : EdgeInsets.zero,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Content cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildInfoCard(
      bool isLightTheme, String category, Map<String, Color> themeColors) {
    final Color cardBgColor =
        isLightTheme ? themeColors['card']! : themeColors['surface']!;
    final Color textColor = isLightTheme
        ? themeColors['deepBlue']!
        : themeColors['card']!.withOpacity(0.85);
    final Color iconColor = themeColors['primary']!;

    return Card(
      elevation: kIsWeb ? 4 : 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBgColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(CupertinoIcons.info_circle_fill, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Did You Know?',
                    style: UserDashboardFonts.largeTextSemiBold.copyWith(
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.3),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      _currentFact.isNotEmpty
                          ? _currentFact
                          : getDidYouKnowFact(category),
                      key: ValueKey(_currentFact),
                      style: UserDashboardFonts.bodyText.copyWith(
                        color: textColor.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getIconForCategory(String category) {
    switch (category) {
      case 'Marine Life':
        return CupertinoIcons.paw;
      case 'Conservation':
        return CupertinoIcons.shield_lefthalf_fill;
      case 'Regulations':
        return CupertinoIcons.doc_text_search;
      case 'Ocean Tech':
        return CupertinoIcons.gear_alt_fill;
      default:
        return CupertinoIcons.book_fill;
    }
  }

  String getDidYouKnowFact(String category) {
    Map<String, List<String>> facts = {
      'Marine Life': [
        "The blue whale is the largest animal on Earth, reaching lengths of up to 100 feet.",
        "Coral reefs, often called 'rainforests of the sea', support about 25% of all marine life.",
        "Some jellyfish are bioluminescent, meaning they can produce their own light.",
        "The ocean produces over 70% of the oxygen we breathe through marine plants.",
        "There are more species of fish in the ocean than there are species of birds, reptiles, and mammals combined.",
        "The deepest part of the ocean, the Mariana Trench, is deeper than Mount Everest is tall.",
        "Dolphins have names for each other and can recognize themselves in mirrors.",
        "Sea turtles can live for over 100 years and migrate thousands of miles.",
        "The ocean contains 97% of Earth's water, but only 5% has been explored.",
        "Whales can communicate across entire ocean basins using low-frequency sounds."
      ],
      'Conservation': [
        "It's estimated that by 2050, there could be more plastic than fish in the ocean by weight.",
        "Marine Protected Areas (MPAs) help conserve biodiversity and rebuild fish stocks.",
        "Over 90% of the Earth's volcanic activity occurs in the oceans.",
        "Ocean acidification is happening 10 times faster than any time in the past 55 million years.",
        "Coral reefs provide habitat for 25% of all marine species despite covering less than 1% of the ocean floor.",
        "Overfishing affects 33% of global fish stocks, with 60% being fished at maximum sustainable levels.",
        "Marine debris affects over 800 species worldwide, with plastic being the most common type.",
        "Ocean warming is causing fish to migrate toward the poles at an average rate of 72 km per decade.",
        "Mangrove forests can store up to 4 times more carbon than tropical rainforests.",
        "The Great Pacific Garbage Patch is twice the size of Texas and contains 1.8 trillion pieces of plastic."
      ],
      'Regulations': [
        "The United Nations Convention on the Law of the Sea (UNCLOS) provides the legal framework for most marine activities.",
        "Many countries have strict quotas and seasonal closures for fishing to prevent overexploitation.",
        "Ballast water from ships can introduce invasive species to new marine environments if not managed properly.",
        "The International Maritime Organization (IMO) regulates shipping safety and environmental protection.",
        "Marine spatial planning helps balance conservation with economic activities in ocean areas.",
        "The Paris Agreement includes ocean protection as a key component of climate action.",
        "Many countries require fishing vessels to use Vessel Monitoring Systems (VMS) for tracking.",
        "The Convention on Biological Diversity includes specific targets for marine conservation.",
        "International cooperation is essential for managing migratory fish stocks that cross national boundaries.",
        "Marine pollution laws often include strict penalties for oil spills and waste dumping."
      ],
      'Ocean Tech': [
        "Remotely Operated Vehicles (ROVs) allow scientists to explore depths humans cannot reach.",
        "Satellite imagery is crucial for monitoring ocean currents, temperatures, and illegal fishing.",
        "Acoustic technology is used to map the seabed and study marine animal communications.",
        "Autonomous Underwater Vehicles (AUVs) can operate independently for months at a time.",
        "Ocean gliders can collect data while drifting with ocean currents for extended periods.",
        "Underwater drones are revolutionizing marine research and conservation efforts.",
        "Artificial intelligence helps identify marine species and track their populations.",
        "3D printing is being used to create artificial coral reefs for restoration projects.",
        "Blockchain technology is being used to track sustainable seafood from ocean to plate.",
        "Virtual reality allows people to explore ocean depths without getting wet."
      ],
    };

    // Use a deterministic seed based on category and current time
    final random = math.Random(
        widget.category.hashCode + DateTime.now().millisecondsSinceEpoch);
    List<String> categoryFacts =
        facts[category] ?? ["Oceans cover over 70% of the Earth's surface."];
    return categoryFacts[random.nextInt(categoryFacts.length)];
  }

  Widget _buildSocialShareButtons(String content) {
    return const SizedBox.shrink();
  }
}

class StaticWavePainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  const StaticWavePainter({
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final amplitude1 = height * 0.025;
    final amplitude2 = height * 0.02;
    final amplitude3 = height * 0.015;

    final period1 = width * 1.2;
    final period2 = width * 1.4;
    final period3 = width * 1.0;

    final baseHeight1 = height * 0.85;
    final baseHeight2 = height * 0.88;
    final baseHeight3 = height * 0.91;

    final double animationOffset = width * 0.1;

    final path1 = Path();
    final path2 = Path();
    final path3 = Path();

    path1.moveTo(0, baseHeight1);
    for (double x = 0; x <= width; x += 5) {
      final y = baseHeight1 -
          amplitude1 *
              math.sin(2 * math.pi * ((x + animationOffset * 1.0) / period1) +
                  math.pi * 0.5) -
          amplitude1 *
              0.3 *
              math.sin(4 * math.pi * ((x - animationOffset * 0.4) / period1));
      path1.lineTo(x, y);
    }
    path1.lineTo(width, height);
    path1.lineTo(0, height);
    path1.close();

    path2.moveTo(0, baseHeight2);
    for (double x = 0; x <= width; x += 5) {
      final y = baseHeight2 -
          amplitude2 *
              math.sin(2 * math.pi * ((x - animationOffset * 0.7) / period2) +
                  math.pi * 0.2) -
          amplitude2 *
              0.4 *
              math.cos(3 * math.pi * ((x + animationOffset * 0.3) / period2));
      path2.lineTo(x, y);
    }
    path2.lineTo(width, height);
    path2.lineTo(0, height);
    path2.close();

    path3.moveTo(0, baseHeight3);
    for (double x = 0; x <= width; x += 5) {
      final y = baseHeight3 -
          amplitude3 *
              math.sin(2 * math.pi * ((x + animationOffset * 0.5) / period3)) -
          amplitude3 *
              0.5 *
              math.cos(5 * math.pi * ((x - animationOffset * 0.2) / period3) +
                  math.pi * 0.8);
      path3.lineTo(x, y);
    }
    path3.lineTo(width, height);
    path3.lineTo(0, height);
    path3.close();

    final double opacity1 = isDark ? 0.12 : 0.20;
    final double opacity2 = isDark ? 0.09 : 0.15;
    final double opacity3 = isDark ? 0.06 : 0.10;

    final paint1 = Paint()
      ..color = primaryColor.withOpacity(opacity1)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = secondaryColor.withOpacity(opacity2)
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..color = primaryColor.withOpacity(opacity3)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path3, paint3);
    canvas.drawPath(path2, paint2);
    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(covariant StaticWavePainter oldDelegate) =>
      isDark != oldDelegate.isDark ||
      primaryColor != oldDelegate.primaryColor ||
      secondaryColor != oldDelegate.secondaryColor;
}
