import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';

/// Screen shown when user's access has been denied/suspended
class AccessDeniedScreen extends ConsumerWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. ATMOSPHERIC BACKGROUND
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A), // Slate 900
            ),
          ),
          
          // Tactical Red Glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.errorRed.withOpacity(0.15),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 5.seconds, curve: Curves.easeInOut),
          ),

          // 2. GLASSMORPHIC LAYER
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 3. CONTENT
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TACTICAL ERROR ICON
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.errorRed.withOpacity(0.05),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.gpp_bad_rounded,
                        color: AppTheme.errorRed,
                        size: 64,
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                    const Gap(40),

                    // HEADER CARD (ASSEMYTRICAL)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(40),
                          bottomLeft: Radius.circular(40),
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'ACCESS RESTRICTED',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: AppTheme.errorRed,
                            ),
                          ),
                          const Gap(16),
                          Text(
                            'Authentication Terminated',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const Gap(16),
                          Text(
                            'Your access to the LIGTAS network has been denied or suspended by the network administrator. Your identity has been flagged for review.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white60,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

                    const Gap(32),

                    // IDENTITY CARD
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fingerprint_rounded, color: Colors.white38, size: 20),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              'Flagged Identity: ${user?.email ?? "Unknown"}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const Gap(48),

                    // RE-AUTH / SIGN OUT
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(authControllerProvider.notifier).logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorRed.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: AppTheme.errorRed.withOpacity(0.3)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded, size: 20),
                            const Gap(12),
                            Text(
                              'CLOSE SECURE LINK',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                    
                    const Gap(24),
                    
                    TextButton(
                      onPressed: () {}, // Link to support or contact
                      child: Text(
                        'CONTACT SYSTEMS ADMIN',
                        style: GoogleFonts.outfit(
                          color: Colors.white38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
