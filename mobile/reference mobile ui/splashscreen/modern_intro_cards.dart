import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobileapplication/authenticationpages/loginpage/login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobileapplication/utils/performance_utils.dart';
import 'package:mobileapplication/splashscreen/widgets/modern_card_form.dart';
import 'package:glassmorphism/glassmorphism.dart';

/// Ultra-beautiful intro cards with smooth animations and modern design
class ModernIntroCards extends StatefulWidget {
  const ModernIntroCards({Key? key}) : super(key: key);

  @override
  State<ModernIntroCards> createState() => _ModernIntroCardsState();
}

class _ModernIntroCardsState extends State<ModernIntroCards>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _exitController;
  final Map<int, AnimationController> _iconControllers = {};
  final Map<int, Animation<double>> _iconAnimations = {};
  bool _isExiting = false;

  final List<IntroCardData> _cards = [
    IntroCardData(
      title: "Welcome to Marine Guard",
      description:
          "Your companion for marine protection. Stay informed about ban periods, report violations, and learn about ocean conservation.",
      icon: Icons.waves_rounded,
      color: Color(0xFF007AFF),
      gradient: [Color(0xFF007AFF), Color(0xFF0051D5)],
    ),
    IntroCardData(
      title: "Check Ban Periods",
      description:
          "View fishing ban schedules to know when fishing is allowed or restricted. Stay compliant with marine regulations.",
      icon: Icons.calendar_today_rounded,
      color: Color(0xFF34C759),
      gradient: [Color(0xFF34C759), Color(0xFF28A745)],
    ),
    IntroCardData(
      title: "Report Violations",
      description:
          "Report illegal fishing activities and marine violations directly to authorities. Help protect our oceans.",
      icon: Icons.report_problem_rounded,
      color: Color(0xFFFF3B30),
      gradient: [Color(0xFFFF3B30), Color(0xFFDC3545)],
    ),
    IntroCardData(
      title: "Learn & Educate",
      description:
          "Explore ocean education content about marine life, conservation, safety, and regulations to become a better steward of the sea.",
      icon: Icons.school_rounded,
      color: Color(0xFFFF9500),
      gradient: [Color(0xFFFF9500), Color(0xFFFF6B00)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Fade animation for initial load only
    _fadeController = AnimationController(
      vsync: this,
      duration: AnimationDurations.normal,
    );
    _fadeController.forward();

    // Exit animation controller for smooth card dismissal
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Create animation controllers for each card's icon
    for (int i = 0; i < _cards.length; i++) {
      _iconControllers[i] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _iconAnimations[i] = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _iconControllers[i]!,
          curve: Curves.elasticOut,
        ),
      );
    }

    // Animate first card icon
    _iconControllers[0]?.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _exitController.dispose();
    for (var controller in _iconControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _cards.length - 1) {
      _pageController.nextPage(
        duration: AnimationDurations.normal,
        curve: AnimationCurves.standard,
      );
    } else {
      _showPreferenceDialog();
    }
  }

  void _skip() {
    _showPreferenceDialog();
  }

  Future<void> _showPreferenceDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentCard = _cards[_currentPage];
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate dynamic height based on screen size, ensuring enough space for text
              final screenHeight = MediaQuery.of(context).size.height;
              final dialogHeight = (screenHeight * 0.35).clamp(250.0, 350.0);
              
              return GlassmorphicContainer(
                    width: double.infinity,
                    height: dialogHeight,
                    borderRadius: 24,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 2,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isDark
                            ? Colors.white.withOpacity(0.15)
                            : Colors.white.withOpacity(0.9),
                        isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.white.withOpacity(0.7),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        currentCard.color.withOpacity(0.4),
                        currentCard.color.withOpacity(0.1),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Show Intro Cards?',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Gap(12),
                          // Use Flexible with proper text wrapping to handle long text
                          Flexible(
                            child: Text(
                              'Would you like to see these intro cards again when you open the app?',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black87,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const Gap(20),
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(
                                  'Don\'t Show',
                                  style: GoogleFonts.inter(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: currentCard.gradient,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).pop(true),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      child: Text(
                                        'Always Show',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ],
                        ),
                      ),
                    );
            },
          ),
        ),
      ),
    );

    if (result != null) {
      await _savePreference(result);
      await _animateExit();
      _navigateToLogin();
    }
  }

  Future<void> _savePreference(bool alwaysShow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'intro_cards_preference',
      alwaysShow ? 'always' : 'never',
    );
  }

  // Animate cards exit with light fade and scale animation
  Future<void> _animateExit() async {
    if (_isExiting) return;
    
    setState(() {
      _isExiting = true;
    });
    
    // Start exit animation
    await _exitController.forward();
    
    // Small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentCard = _cards[_currentPage];

    // Create exit animation
    final exitAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInOut,
      ),
    );
    
    final scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInOut,
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF000000) : Color(0xFFF5F5F7),
      body: Stack(
        children: [
          // Main content with exit animation
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: FadeTransition(
                opacity: exitAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Column(
                    children: [
                      // Cards - no animations during swipe to prevent jumping
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                              // Animate icon only when page becomes visible
                              final controller = _iconControllers[index];
                              if (controller != null && !controller.isCompleted) {
                                controller.forward();
                              }
                            });
                          },
                          itemCount: _cards.length,
                          physics: _isExiting 
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _buildCard(_cards[index], isDark, index);
                          },
                        ),
                      ),

                      Gap(Spacing.xl),

                      // Beautiful page indicator
                      _buildPageIndicator(isDark),

                      Gap(Spacing.xl),

                      // Primary button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                        child: _buildPrimaryButton(currentCard, isDark),
                      ),

                      Gap(MediaQuery.of(context).padding.bottom + Spacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating skip button - doesn't interfere with content
          SafeArea(
            child: FadeTransition(
              opacity: exitAnimation,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildFloatingSkipButton(isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(IntroCardData card, bool isDark, int index) {
    // Use modern card form with glassmorphism
    // No padding needed - form handles its own spacing
    return ModernCardForm(
      title: card.title,
      description: card.description,
      icon: card.icon,
      primaryColor: card.color,
      gradient: card.gradient,
      isDark: isDark,
      fadeAnimation: _fadeAnimation,
    );
  }

  Widget _buildFloatingSkipButton(bool isDark) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 100, // Prevent overflow
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _skip,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      color: isDark
                          ? Colors.white.withOpacity(0.8)
                          : Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Gap(4),
                Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: isDark
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _cards.length,
        (index) {
          final isActive = index == _currentPage;
          final card = _cards[index];
          
          return AnimatedContainer(
            duration: AnimationDurations.normal,
            curve: AnimationCurves.standard,
            margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
            width: isActive ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                      colors: [
                        card.gradient[0],
                        card.gradient[1],
                      ],
                    )
                  : null,
              color: isActive
                  ? null
                  : (isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.15)),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: card.color.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrimaryButton(IntroCardData card, bool isDark) {
    final isLastPage = _currentPage >= _cards.length - 1;
    
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            card.gradient[0],
            card.gradient[1],
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: card.color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _nextPage,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastPage ? 'Get Started' : 'Continue',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                Gap(Spacing.sm),
                Icon(
                  isLastPage
                      ? Icons.arrow_forward_rounded
                      : Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Animation<double> get _fadeAnimation {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: AnimationCurves.standard,
      ),
    );
  }
}

class IntroCardData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  IntroCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}

/// Manager for intro cards preferences
class IntroCardManager {
  static Future<void> resetIntroCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('intro_cards_preference');
    await prefs.setBool('show_intro_cards', true);
  }

  static Future<bool> shouldShowIntroCards() async {
    final prefs = await SharedPreferences.getInstance();
    final preference = prefs.getString('intro_cards_preference');
    
    if (preference == 'never') {
      return false;
    }
    // Show by default or if preference is 'always'
    return true;
  }
}
