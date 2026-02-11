import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';

/// Splash logo widget with glassmorphism and animations
class SplashLogoWidget extends StatelessWidget {
  final String? logoPath;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double> rotationAnimation;
  final Color primaryColor;
  final Color backgroundColor;
  final bool isLargeScreen;

  const SplashLogoWidget({
    super.key,
    this.logoPath,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.rotationAnimation,
    required this.primaryColor,
    required this.backgroundColor,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        fadeAnimation,
        scaleAnimation,
        rotationAnimation,
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: GlassmorphicContainer(
              width: isLargeScreen ? 180 : 150,
              height: isLargeScreen ? 180 : 150,
              borderRadius: 90,
              blur: 20,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.5),
                  primaryColor.withOpacity(0.2),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: rotationAnimation.value,
                    child: Container(
                      width: isLargeScreen ? 180 : 150,
                      height: isLargeScreen ? 180 : 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            primaryColor.withOpacity(0.0),
                            primaryColor.withOpacity(0.3),
                            primaryColor.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  if (logoPath != null)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        logoPath!,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) => _buildPlaceholderIcon(
                              primaryColor,
                              isLargeScreen,
                            ),
                      ),
                    )
                  else
                    _buildPlaceholderIcon(primaryColor, isLargeScreen),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderIcon(Color color, bool isLargeScreen) {
    return Icon(
      Icons.shield_rounded,
      size: isLargeScreen ? 90 : 75,
      color: color,
    );
  }
}

/// App title widget with gradient text
class SplashTitleWidget extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Color primaryColor;
  final Color accentColor;
  final String title;
  final bool isLargeScreen;

  const SplashTitleWidget({
    super.key,
    required this.fadeAnimation,
    required this.primaryColor,
    required this.accentColor,
    required this.title,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, accentColor],
          ).createShader(bounds);
        },
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: isLargeScreen ? 36 : 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

/// Tagline widget for splash screen
class SplashTaglineWidget extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Color textColor;
  final String tagline;
  final bool isLargeScreen;

  const SplashTaglineWidget({
    super.key,
    required this.fadeAnimation,
    required this.textColor,
    required this.tagline,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Text(
        tagline,
        style: GoogleFonts.inter(
          fontSize: isLargeScreen ? 17 : 15,
          color: textColor.withOpacity(0.8),
          letterSpacing: 0.8,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
