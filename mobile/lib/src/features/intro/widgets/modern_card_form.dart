import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/design_system/app_spacing.dart';

/// Modern form-like card container for intro cards (reference UI style)
class ModernCardForm extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final List<Color> gradient;
  final bool isDark;
  final Animation<double>? fadeAnimation;

  const ModernCardForm({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.gradient,
    required this.isDark,
    this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconSection(),
            const Gap(20),
            _buildFormCard(context, constraints.maxHeight),
          ],
        );
      },
    );
  }

  Widget _buildIconSection() {
    final iconContainer = Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.5),
            blurRadius: 35,
            spreadRadius: 6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, size: 50, color: Colors.white),
    );

    final wrappedIcon = Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 12, left: 40, right: 40),
      child: Center(child: iconContainer),
    );

    if (fadeAnimation != null) {
      return FadeTransition(opacity: fadeAnimation!, child: wrappedIcon);
    }

    return wrappedIcon;
  }

  Widget _buildFormCard(BuildContext context, double availableHeight) {
    const iconSectionHeight = 152.0;
    const gapHeight = 20.0;
    const reservedHeight = iconSectionHeight + gapHeight;
    final cardAvailableHeight =
        availableHeight > reservedHeight
            ? availableHeight - reservedHeight
            : availableHeight * 0.5;
    final cardHeight = (cardAvailableHeight * 0.95).clamp(320.0, 420.0);

    final cardWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: cardHeight,
        borderRadius: 28,
        blur: 25,
        alignment: Alignment.topCenter,
        border: 1.5,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark
                ? Colors.white.withOpacity(0.12)
                : Colors.white.withOpacity(0.85),
            isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.65),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.4),
            primaryColor.withOpacity(0.15),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: Colors.white),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withOpacity(0.3),
                            primaryColor.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(14),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(14),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.2),
                      primaryColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.black.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.04),
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            height: 1.7,
                            color:
                                isDark
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.1,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return cardWidget
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }
}
