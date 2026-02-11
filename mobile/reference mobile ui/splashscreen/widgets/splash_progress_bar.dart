import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Beautiful progress bar with phase indicators
class SplashProgressBar extends StatelessWidget {
  final int numberOfPhases;
  final int currentPhase;
  final AnimationController phaseProgressController;
  final double overallProgress;
  final Color activeColor;
  final Color inactiveColor;
  final Color glowColor;
  final double height;

  const SplashProgressBar({
    Key? key,
    required this.numberOfPhases,
    required this.currentPhase,
    required this.phaseProgressController,
    required this.overallProgress,
    required this.activeColor,
    required this.inactiveColor,
    required this.glowColor,
    this.height = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final phaseWidth = constraints.maxWidth / numberOfPhases;
        return Container(
          width: constraints.maxWidth,
          height: height,
          decoration: BoxDecoration(
            color: inactiveColor,
            borderRadius: BorderRadius.circular(height),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Overall progress background
              Container(
                width: constraints.maxWidth * overallProgress,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activeColor,
                      activeColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(height),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ],
                ),
              ),
              // Individual phase progress segments
              Row(
                children: List.generate(numberOfPhases, (index) {
                  return AnimatedBuilder(
                    animation: phaseProgressController,
                    builder: (context, child) {
                      double progress = 0.0;
                      if (index < currentPhase) {
                        progress = 1.0;
                      } else if (index == currentPhase) {
                        progress = phaseProgressController.value;
                      }

                      return Container(
                        width: phaseWidth,
                        height: height,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: progress > 0
                            ? Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      activeColor,
                                      activeColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(height / 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: glowColor.withOpacity(0.6),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                width: phaseWidth * progress,
                              )
                            : null,
                      );
                    },
                  );
                }),
              ),
              // Glowing active phase indicator
              AnimatedBuilder(
                animation: phaseProgressController,
                builder: (context, child) {
                  return Positioned(
                    left: (phaseWidth * currentPhase) +
                        (phaseWidth * phaseProgressController.value) - 6,
                    top: height / 2 - 6,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withOpacity(0.9),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Loading phase text widget
class SplashPhaseText extends StatelessWidget {
  final String phaseText;
  final Color textColor;
  final bool isLargeScreen;

  const SplashPhaseText({
    Key? key,
    required this.phaseText,
    required this.textColor,
    this.isLargeScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        phaseText,
        key: ValueKey<String>(phaseText),
        style: GoogleFonts.inter(
          fontSize: isLargeScreen ? 17 : 15,
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Percentage text widget
class SplashPercentageText extends StatelessWidget {
  final double progress;
  final Color textColor;

  const SplashPercentageText({
    Key? key,
    required this.progress,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '${(progress * 100).toInt()}%',
      style: GoogleFonts.inter(
        fontSize: 16,
        color: textColor,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );
  }
}

