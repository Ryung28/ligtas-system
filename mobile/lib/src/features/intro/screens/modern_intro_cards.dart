import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/animation_constants.dart';
import '../models/intro_card_data.dart';
import '../services/intro_preference_service.dart';
import '../widgets/modern_card_form.dart';

/// Intro/onboarding cards with glassmorphism (reference UI style)
class ModernIntroCards extends StatefulWidget {
  const ModernIntroCards({super.key});

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
  bool _isExiting = false;

  final List<IntroCardData> _cards = [
    IntroCardData(
      title: 'Welcome to LIGTAS',
      description:
          'Your loan and inventory management companion. Track loans, manage inventory, and scan QR codes for quick transactions.',
      icon: Icons.shield_rounded,
      color: Color(0xFF1976D2),
      gradient: [Color(0xFF1976D2), Color(0xFF1565C0)],
    ),
    IntroCardData(
      title: 'Active Loans',
      description:
          'View and manage all your active loans in one place. Stay on top of repayment schedules and loan status.',
      icon: Icons.list_alt_rounded,
      color: Color(0xFF34C759),
      gradient: [Color(0xFF34C759), Color(0xFF28A745)],
    ),
    IntroCardData(
      title: 'Inventory Management',
      description:
          'Track your inventory items with ease. Add, update, and organize items efficiently for better asset management.',
      icon: Icons.inventory_rounded,
      color: Color(0xFFFF9500),
      gradient: [Color(0xFFFF9500), Color(0xFFFF6B00)],
    ),
    IntroCardData(
      title: 'QR Scanner',
      description:
          'Scan QR codes to quickly process transactions and link items. Fast, accurate, and built for productivity.',
      icon: Icons.qr_code_scanner_rounded,
      color: Color(0xFF9C27B0),
      gradient: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AnimationDurations.normal,
    );
    _fadeController.forward();

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    for (var i = 0; i < _cards.length; i++) {
      _iconControllers[i] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    }
    _iconControllers[0]?.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _exitController.dispose();
    for (final c in _iconControllers.values) {
      c.dispose();
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
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final dialogHeight = (screenHeight * 0.35).clamp(
                    250.0,
                    350.0,
                  );

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
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: Text(
                                  'Don\'t Show',
                                  style: GoogleFonts.inter(
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black54,
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
                                    onTap:
                                        () => Navigator.of(context).pop(true),
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
      await IntroCardManager.savePreference(result);
      await _animateExit();
      _navigateToMain();
    }
  }

  Future<void> _animateExit() async {
    if (_isExiting) return;
    setState(() => _isExiting = true);
    await _exitController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _navigateToMain() {
    if (mounted) context.go('/login');
  }

  Animation<double> get _fadeAnimation {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: AnimationCurves.standard),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentCard = _cards[_currentPage];

    final exitAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );

    final scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF000000) : Color(0xFFF5F5F7),
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: FadeTransition(
                opacity: exitAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                              final controller = _iconControllers[index];
                              if (controller != null &&
                                  !controller.isCompleted) {
                                controller.forward();
                              }
                            });
                          },
                          itemCount: _cards.length,
                          physics:
                              _isExiting
                                  ? const NeverScrollableScrollPhysics()
                                  : const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _buildCard(_cards[index], index);
                          },
                        ),
                      ),
                      Gap(AppSpacing.xl),
                      _buildPageIndicator(isDark),
                      Gap(AppSpacing.xl),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: _buildPrimaryButton(currentCard, isDark),
                      ),
                      Gap(
                        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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

  Widget _buildCard(IntroCardData card, int index) {
    return ModernCardForm(
      title: card.title,
      description: card.description,
      icon: card.icon,
      primaryColor: card.color,
      gradient: card.gradient,
      isDark: Theme.of(context).brightness == Brightness.dark,
      fadeAnimation: _fadeAnimation,
    );
  }

  Widget _buildFloatingSkipButton(bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark
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
                      color:
                          isDark
                              ? Colors.white.withOpacity(0.8)
                              : Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Gap(4),
                Icon(
                  Icons.close_rounded,
                  size: 14,
                  color:
                      isDark
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
      children: List.generate(_cards.length, (index) {
        final isActive = index == _currentPage;
        final card = _cards[index];

        return AnimatedContainer(
          duration: AnimationDurations.normal,
          curve: AnimationCurves.standard,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient:
                isActive
                    ? LinearGradient(
                      colors: [card.gradient[0], card.gradient[1]],
                    )
                    : null,
            color:
                isActive
                    ? null
                    : (isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.15)),
            borderRadius: BorderRadius.circular(4),
            boxShadow:
                isActive
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
      }),
    );
  }

  Widget _buildPrimaryButton(IntroCardData card, bool isDark) {
    final isLastPage = _currentPage >= _cards.length - 1;

    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [card.gradient[0], card.gradient[1]]),
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
                Gap(AppSpacing.sm),
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
}
