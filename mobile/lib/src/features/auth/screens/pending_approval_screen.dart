import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';

class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

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
          
          // Tactical Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.warningOrange.withOpacity(0.15),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds, curve: Curves.easeInOut),
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
                    // TACTICAL ICON WITH PULSE
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.warningOrange.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.warningOrange.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppTheme.warningOrange,
                        size: 64,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .shimmer(duration: 2.seconds, color: Colors.white24),

                    const Gap(40),

                    // HEADER CARD (ASSEMYTRICAL)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'REGISTRATION COMPLETE',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: AppTheme.warningOrange,
                            ),
                          ),
                          const Gap(16),
                          Text(
                            'Awaiting Command Authorization',
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
                            'Your credentials have been logged. Access to the LIGTAS network is restricted until an Administrator approves your deployment.',
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

                    // STATUS TRACKER (NEUMORPHIC STYLE)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white38, size: 20),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              'Identity Source: ${user?.email ?? "Unknown"}',
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
                        onPressed: () async {
                          await ref.read(authControllerProvider.notifier).logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded, size: 20),
                            const Gap(12),
                            Text(
                              'TERMINATE SESSION',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                    
                    const Gap(24),
                    
                    TextButton(
                      onPressed: () => ref.read(authControllerProvider.notifier).refreshProfile(),
                      child: Text(
                        'CHECK STATUS',
                        style: GoogleFonts.outfit(
                          color: AppTheme.warningOrange.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
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
