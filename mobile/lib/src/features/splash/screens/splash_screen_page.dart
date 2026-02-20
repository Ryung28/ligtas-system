import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/branding.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/widgets/atmospheric_background.dart';
import '../../intro/services/intro_preference_service.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  Timer? _timer;
  String _statusMessage = 'INITIALIZING SYSTEM...';
  
  final List<String> _statusSequence = [
    'INITIALIZING LIGTAS NETWORK...',
    'SECURING PROTOCOLS...',
    'ESTABLISHING COMMAND BRIDGE...',
    'CONNECTING TO CDRRMO NODES...',
    'AUTHENTICATING HANDSHAKE...',
  ];
  int _statusIdx = 0;

  @override
  void initState() {
    super.initState();
    
    // Cycle through status messages for a "High-Tech" feel
    _timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (_statusIdx < _statusSequence.length - 1) {
        if (mounted) {
          setState(() {
            _statusIdx++;
            _statusMessage = _statusSequence[_statusIdx];
          });
        }
      } else {
        timer.cancel();
      }
    });

    // Main navigation delay extended to 5 seconds
    Future.delayed(const Duration(seconds: 5), _navigateNext);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: Atmospheric Design ──
          const AtmosphericBackground(),
          
          // ── Layer 2: Center Logo & Title ──
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rotating & Pulsing Logo
              Hero(
                tag: 'app_logo',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      'assets/cdrrmo_logo.png', // Corrected Match from LoginScreen
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 120,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(Icons.shield_rounded, size: 50, color: AppTheme.primaryBlue),
                      ),
                    ),
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1500.ms, curve: Curves.easeInOut)
              .animate()
              .fadeIn(duration: 800.ms)
              .blur(begin: const Offset(5, 5), end: Offset.zero),

              const SizedBox(height: 32),

              // Title with modern tracking
              Text(
                Branding.appName.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                  letterSpacing: 4.0,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'FIELD OPERATIONS & LOGISTICS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 60),

              // High-tech status indicator
              Column(
                children: [
                   SizedBox(
                    width: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        backgroundColor: const Color(0xFFF1F5F9),
                        color: AppTheme.primaryBlue,
                        minHeight: 3,
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).scaleX(begin: 0),
                  
                  const SizedBox(height: 16),

                  Text(
                    _statusMessage,
                    style: GoogleFonts.firaCode(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlue.withOpacity(0.8),
                    ),
                  ).animate(key: ValueKey(_statusMessage)).fadeIn(duration: 200.ms),
                ],
              ),
            ],
          ),

          // ── Layer 3: Footer Footer ──
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'DEPARTMENT OF SCIENCE & TECHNOLOGY',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CDRRMO ORO CERVO NETWORK',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1000.ms),
          ),
        ],
      ),
    );
  }
}
