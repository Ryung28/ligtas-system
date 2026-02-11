import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:mobileapplication/authenticationpages/loginpage/login_page.dart';
import 'package:mobileapplication/splashscreen/modern_intro_cards.dart';
import 'package:mobileapplication/splashscreen/widgets/splash_logo_widget.dart';
import 'package:mobileapplication/splashscreen/widgets/splash_progress_bar.dart';
import 'package:mobileapplication/splashscreen/widgets/splash_background_effects.dart';
import 'package:mobileapplication/splashscreen/services/splash_particle_service.dart';
import 'package:mobileapplication/splashscreen/models/splash_particle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Main splash screen page - refactored with modern UI packages
class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _particleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _rotationAnimation;

  bool _showContent = false;
  bool _loadingComplete = false;
  int _currentPhaseIndex = 0;
  double _overallProgress = 0.0;

  List<SplashParticle> _particles = [];
  SplashParticleService? _particleService;

  final List<String> _loadingPhases = [
    "Initializing Systems",
    "Securing Connections",
    "Loading User Data",
    "Optimizing Interface",
    "Finalizing Setup"
  ];

  final Duration _totalLoadingTime =
      const Duration(seconds: kDebugMode ? 3 : 5);
  late Timer _progressTimer;
  late Timer _phaseChangeTimer;

  final String _logoPath = 'assets/MarineGuard-Logo-preview.png';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeParticles(Size screenSize) {
    _particles = SplashParticleService.initializeParticles(
      screenWidth: screenSize.width.toInt(),
      screenHeight: screenSize.height.toInt(),
    );
    _particleService = SplashParticleService(
      particles: _particles,
      screenWidth: screenSize.width.toInt(),
      screenHeight: screenSize.height.toInt(),
    );
  }

  void _initializeAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: Duration(
          milliseconds:
              _totalLoadingTime.inMilliseconds ~/ _loadingPhases.length),
      vsync: this,
    );

    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _mainAnimationController.forward();
    _mainAnimationController.repeat(reverse: false);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showContent = true);
      }
    });

    _setupProgressTimer();
    _setupPhaseTimer();
  }

  void _setupProgressTimer() {
    _progressTimer = Timer.periodic(
      Duration(milliseconds: _totalLoadingTime.inMilliseconds ~/ 100),
      (timer) {
        if (_overallProgress < 1.0) {
          if (mounted) {
            setState(() {
              _overallProgress = (_overallProgress + 0.01).clamp(0.0, 1.0);
              _particleService?.updateParticles();
            });
          }
        } else {
          timer.cancel();
          if (!_loadingComplete) {
            if (mounted) {
              setState(() => _loadingComplete = true);
            }
            Future.delayed(const Duration(milliseconds: 100), () {
              _navigateAfterLoading();
            });
          }
        }
      },
    );
  }

  void _setupPhaseTimer() {
    int phaseDuration =
        _totalLoadingTime.inMilliseconds ~/ _loadingPhases.length;
    _phaseChangeTimer =
        Timer.periodic(Duration(milliseconds: phaseDuration), (timer) {
      if (mounted && _currentPhaseIndex < _loadingPhases.length - 1) {
        setState(() {
          _currentPhaseIndex++;
          _progressAnimationController.reset();
          _progressAnimationController.forward();
        });
      } else if (_currentPhaseIndex >= _loadingPhases.length - 1) {
        timer.cancel();
        if (!_loadingComplete) {
          if (mounted) {
            setState(() => _loadingComplete = true);
          }
          Future.delayed(const Duration(milliseconds: 100), () {
            _navigateAfterLoading();
          });
        }
      }
    });
    _progressAnimationController.forward();
  }

  Future<void> _navigateAfterLoading() async {
    if (!mounted) return;

    final shouldShowCards = await IntroCardManager.shouldShowIntroCards();

    if (shouldShowCards) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ModernIntroCards()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _progressAnimationController.dispose();
    _particleAnimationController.dispose();
    _progressTimer.cancel();
    _phaseChangeTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Initialize particles on first build
    if (_particles.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeParticles(screenSize);
      });
    }

    final primaryColor =
        isDarkMode ? ThemeConfig.darkPrimary : ThemeConfig.lightPrimary;
    final accentColor =
        isDarkMode ? ThemeConfig.darkAccent : ThemeConfig.lightAccent;
    final baseBackgroundColor = isDarkMode
        ? ThemeConfig.darkBackground
        : ThemeConfig.lightGradientStart;
    final gradientEndColor =
        isDarkMode ? ThemeConfig.darkSurface : ThemeConfig.lightGradientEnd;
    final textColor = isDarkMode ? Colors.white : ThemeConfig.lightText;
    final subtlePatternColor = isDarkMode
        ? Colors.white.withOpacity(0.03)
        : Colors.black.withOpacity(0.03);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [baseBackgroundColor, gradientEndColor],
            stops: const [0.2, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background effects
            _buildBackgroundEffects(
              screenSize: screenSize,
              primaryColor: primaryColor,
              accentColor: accentColor,
              subtlePatternColor: subtlePatternColor,
            ),

            // Main content
            _buildMainContent(
              isLargeScreen: isLargeScreen,
              primaryColor: primaryColor,
              accentColor: accentColor,
              baseBackgroundColor: baseBackgroundColor,
              textColor: textColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundEffects({
    required Size screenSize,
    required Color primaryColor,
    required Color accentColor,
    required Color subtlePatternColor,
  }) {
    return Stack(
      children: [
        // Subtle background pattern
        Positioned.fill(
          child: SplashBackgroundEffects.buildSubtlePattern(
            color: subtlePatternColor,
          ),
        ),

        // Particle effect
        if (_particles.isNotEmpty)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleAnimationController,
              builder: (context, child) {
                return SplashBackgroundEffects.buildParticlePainter(_particles);
              },
            ),
          ),

        // Wave animations
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return SplashBackgroundEffects.buildWavePainter(
                waveAnimation: _waveAnimation.value,
                color1: primaryColor.withOpacity(0.07),
                color2: accentColor.withOpacity(0.09),
              );
            },
          ),
        ),

        // Radial gradient glow
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _mainAnimationController,
            builder: (context, child) {
              return SplashBackgroundEffects.buildRadialGradientGlow(
                center: Offset(
                    screenSize.width * 0.5, screenSize.height * 0.4),
                colors: [
                  primaryColor.withOpacity(0.04 +
                      0.04 *
                          math.sin(_mainAnimationController.value * math.pi * 2)),
                  Colors.transparent,
                ],
                radius: screenSize.width * 0.8 +
                    (50 * math.sin(_mainAnimationController.value * math.pi)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent({
    required bool isLargeScreen,
    required Color primaryColor,
    required Color accentColor,
    required Color baseBackgroundColor,
    required Color textColor,
  }) {
    return AnimatedOpacity(
      opacity: _showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // Logo with glassmorphism
            SplashLogoWidget(
              logoPath: _logoPath,
              fadeAnimation: _fadeAnimation,
              scaleAnimation: _scaleAnimation,
              rotationAnimation: _rotationAnimation,
              primaryColor: primaryColor,
              backgroundColor: baseBackgroundColor,
              isLargeScreen: isLargeScreen,
            ),

            Gap(isLargeScreen ? 32 : 28),

            // App title
            SplashTitleWidget(
              fadeAnimation: _fadeAnimation,
              primaryColor: primaryColor,
              accentColor: accentColor,
              isLargeScreen: isLargeScreen,
            ),

            Gap(12),

            // Tagline
            SplashTaglineWidget(
              fadeAnimation: _fadeAnimation,
              textColor: textColor,
              isLargeScreen: isLargeScreen,
            ),

            const Spacer(flex: 2),

            // Progress section
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 100 : 50),
              child: Column(
                children: [
                  if (!_loadingComplete)
                    SplashPhaseText(
                      phaseText: _loadingPhases[_currentPhaseIndex],
                      textColor: textColor,
                      isLargeScreen: isLargeScreen,
                    ),
                  Gap(16),
                  SplashProgressBar(
                    numberOfPhases: _loadingPhases.length,
                    currentPhase: _currentPhaseIndex,
                    phaseProgressController: _progressAnimationController,
                    overallProgress: _overallProgress,
                    activeColor: accentColor,
                    inactiveColor: textColor.withOpacity(0.15),
                    glowColor: primaryColor,
                    height: 12,
                  ),
                ],
              ),
            ),

            Gap(24),

            // Percentage with beautiful spinner
            if (!_loadingComplete)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitPulse(
                    color: primaryColor,
                    size: 20,
                  ),
                  Gap(12),
                  SplashPercentageText(
                    progress: _overallProgress,
                    textColor: primaryColor,
                  ),
                ],
              ),

            const Spacer(flex: 1),

            // Version text
            Text(
              'Version 1.0.0',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: textColor.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),

            Gap(isLargeScreen ? 60 : 40),
          ],
        ),
      ),
    );
  }
}
