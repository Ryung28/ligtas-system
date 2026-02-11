import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/branding.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/components/brand_logo.dart';

/// Login screen header: icon, title, subtitle
class LoginHeader extends StatelessWidget {
  final bool compact;

  const LoginHeader({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandLogo(
          width: compact ? 160 : 200,
          height: compact ? 70 : 90,
          fit: BoxFit.contain,
        ),
        SizedBox(height: compact ? 20 : 28),
        Text(
          Branding.appName,
          style: GoogleFonts.roboto(
            fontSize: compact ? 26 : 30,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppTheme.neutralGray900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue',
          style: GoogleFonts.roboto(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppTheme.neutralGray600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
