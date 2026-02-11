import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:gap/gap.dart';

/// Modern intro card content with glassmorphic container
class IntroCardContent extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final List<Color> gradient;
  final bool isDark;
  final Animation<double>? scaleAnimation;

  const IntroCardContent({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.gradient,
    required this.isDark,
    this.scaleAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon with glassmorphic container
        _buildIconContainer(),

        Gap(40),

        // Title and description wrapped in glassmorphic card
        _buildContentCard(),
      ],
    );
  }

  Widget _buildIconContainer() {
    Widget iconWidget = Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 70,
        color: Colors.white,
      ),
    );

    if (scaleAnimation != null) {
      return ScaleTransition(
        scale: scaleAnimation!,
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  Widget _buildContentCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 280,
        borderRadius: 32,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.7),
            isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.5),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.3),
            primaryColor.withOpacity(0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title with gradient
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ).createShader(bounds);
                },
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              Gap(20),

              // Description in a subtle container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.6,
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

