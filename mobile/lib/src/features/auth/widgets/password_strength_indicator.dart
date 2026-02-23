import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design_system/app_theme.dart';

enum PasswordStrength { none, weak, fair, good, strong }

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  PasswordStrength get strength {
    if (password.isEmpty) return PasswordStrength.none;
    
    int score = 0;
    
    // Length checks
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // Character type checks
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    if (score <= 5) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  Color get strengthColor {
    switch (strength) {
      case PasswordStrength.none:
        return Colors.transparent;
      case PasswordStrength.weak:
        return AppTheme.errorRed;
      case PasswordStrength.fair:
        return AppTheme.warningAmber;
      case PasswordStrength.good:
        return AppTheme.successGreenLight;
      case PasswordStrength.strong:
        return AppTheme.successGreen;
    }
  }

  String get strengthText {
    switch (strength) {
      case PasswordStrength.none:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  double get strengthPercent {
    switch (strength) {
      case PasswordStrength.none:
        return 0;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.fair:
        return 0.5;
      case PasswordStrength.good:
        return 0.75;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strengthPercent,
                  backgroundColor: AppTheme.neutralGray200,
                  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strengthText,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: strengthColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final requirements = [
      _Requirement('At least 8 characters', password.length >= 8),
      _Requirement('1 uppercase letter', password.contains(RegExp(r'[A-Z]'))),
      _Requirement('1 lowercase letter', password.contains(RegExp(r'[a-z]'))),
      _Requirement('1 number', password.contains(RegExp(r'[0-9]'))),
      _Requirement('1 special character', password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password Requirements',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.neutralGray600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ...requirements.map((req) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                req.isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 16,
                color: req.isMet ? AppTheme.successGreen : AppTheme.neutralGray400,
              ),
              const SizedBox(width: 8),
              Text(
                req.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: req.isMet ? AppTheme.successGreen : AppTheme.neutralGray500,
                  fontWeight: req.isMet ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _Requirement {
  final String label;
  final bool isMet;

  _Requirement(this.label, this.isMet);
}
