import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/branding.dart';
import '../../../core/design_system/app_theme.dart';
import '../../intro/services/intro_preference_service.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _navigateNext);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;
    final shouldShowCards = await IntroCardManager.shouldShowIntroCards();
    if (!mounted) return;
    context.go(shouldShowCards ? '/intro' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Pearl White Base
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: Pearl Shimmer Background ──
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF1F5F9),
                ],
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Layer 2: Breathing Aura & Logo ──
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Breathing Glow
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.15),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 2000.ms, curve: Curves.easeInOut),

                    // Hero Logo
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: sentinel.tactile.raised,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            'assets/cdrrmo_logo.png',
                            width: 90,
                            height: 100,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.shield_rounded, size: 50, color: AppTheme.primaryBlue),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),
                  ],
                ),

                const SizedBox(height: 48),

                // ── Layer 3: Staggered Letter Emergence ──
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: Branding.appName.split('').map((char) {
                    return Text(
                      char.toUpperCase(),
                      style: GoogleFonts.lexend(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: sentinel.navy,
                        letterSpacing: 6.0,
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 400 + (Branding.appName.indexOf(char) * 100)))
                               .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // Premium Tagline
                Text(
                  'EQUIPMENT • INVENTORY',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: sentinel.onSurfaceVariant.withOpacity(0.4),
                    letterSpacing: 3.5,
                  ),
                ).animate().fadeIn(delay: 1200.ms),
              ],
            ),
          ),

          // ── Layer 4: Floating Glass Footer ──
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    'DEPARTMENT OF SCIENCE & TECHNOLOGY',
                    style: GoogleFonts.lexend(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: sentinel.navy.withOpacity(0.3),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CDRRMO LIGTAS COORDINATION',
                    style: GoogleFonts.lexend(
                      fontSize: 7,
                      fontWeight: FontWeight.w500,
                      color: sentinel.onSurfaceVariant.withOpacity(0.25),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1500.ms).slideY(begin: 0.2),
          ),
        ],
      ),
    );
  }
}
