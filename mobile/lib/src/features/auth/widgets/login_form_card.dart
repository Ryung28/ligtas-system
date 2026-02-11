import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/app_spacing.dart';

/// Elevated card containing email and password fields
class LoginFormCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final String? emailError;
  final String? passwordError;
  final bool enabled;

  const LoginFormCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    this.emailError,
    this.passwordError,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutralGray900.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.neutralGray900.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Email'),
          SizedBox(height: AppSpacing.xs),
          _buildEmailField(context),
          SizedBox(height: AppSpacing.lg),
          _buildLabel('Password'),
          SizedBox(height: AppSpacing.xs),
          _buildPasswordField(context),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.neutralGray700,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      controller: emailController,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      style: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppTheme.neutralGray900,
      ),
      decoration: InputDecoration(
        hintText: 'you@example.com',
        hintStyle: GoogleFonts.roboto(
          fontSize: 15,
          color: AppTheme.neutralGray400,
          fontWeight: FontWeight.w400,
        ),
        errorText: emailError,
        errorStyle: GoogleFonts.roboto(
          fontSize: 12,
          color: AppTheme.errorRed,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          Icons.mail_outline_rounded,
          size: 22,
          color: AppTheme.neutralGray500,
        ),
        filled: true,
        fillColor: AppTheme.neutralGray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.neutralGray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.neutralGray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return TextFormField(
      controller: passwordController,
      enabled: enabled,
      obscureText: obscurePassword,
      textInputAction: TextInputAction.done,
      style: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppTheme.neutralGray900,
      ),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: GoogleFonts.roboto(
          fontSize: 15,
          color: AppTheme.neutralGray400,
          fontWeight: FontWeight.w400,
        ),
        errorText: passwordError,
        errorStyle: GoogleFonts.roboto(
          fontSize: 12,
          color: AppTheme.errorRed,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          size: 22,
          color: AppTheme.neutralGray500,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            size: 22,
            color: AppTheme.neutralGray500,
          ),
          onPressed: onTogglePassword,
          splashRadius: 20,
        ),
        filled: true,
        fillColor: AppTheme.neutralGray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.neutralGray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.neutralGray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
      ),
    );
  }
}
