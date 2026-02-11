import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/branding.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/components/brand_logo.dart';
import '../../intro/services/intro_preference_service.dart';

/// Simple premium splash screen
class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    final delay = Duration(seconds: kDebugMode ? 1 : 2);
    _timer = Timer(delay, _navigateNext);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;
    final shouldShowCards = await IntroCardManager.shouldShowIntroCards();
    if (!mounted) return;

    if (shouldShowCards) {
      context.go('/intro');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.neutralGray50,
              AppTheme.neutralGray100.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BrandLogo(width: 220, height: 90),
                  const SizedBox(height: 24),
                  Text(
                    Branding.appName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.neutralGray900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Branding.tagline,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.neutralGray600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: 180,
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: AppTheme.neutralGray200,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            // Skip button
            Positioned(
              top: 50,
              right: 20,
              child: SafeArea(
                child: TextButton(
                  onPressed: () {
                    _timer?.cancel();
                    context.go('/dashboard');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Skip to Dashboard',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
}
