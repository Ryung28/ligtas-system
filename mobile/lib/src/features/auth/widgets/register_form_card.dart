import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/app_spacing.dart';

/// Elevated card containing register fields
class RegisterFormCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController organizationController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final String? nameError;
  final String? emailError;
  final String? phoneError;
  final String? organizationError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool enabled;

  const RegisterFormCard({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.organizationController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    this.nameError,
    this.emailError,
    this.phoneError,
    this.organizationError,
    this.passwordError,
    this.confirmPasswordError,
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
          _buildLabel('Full name'),
          SizedBox(height: AppSpacing.xs),
          _buildTextField(
            controller: nameController,
            hintText: 'Juan Dela Cruz',
            errorText: nameError,
            prefixIcon: Icons.person_outline_rounded,
          ),
          SizedBox(height: AppSpacing.lg),
          _buildLabel('Email'),
          SizedBox(height: AppSpacing.xs),
          _buildTextField(
            controller: emailController,
            hintText: 'you@example.com',
            errorText: emailError,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Phone Number'),
                    SizedBox(height: AppSpacing.xs),
                    _buildTextField(
                      controller: phoneController,
                      hintText: '09123456789',
                      errorText: phoneError,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_android_rounded,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Office / Org'),
                    SizedBox(height: AppSpacing.xs),
                    _buildTextField(
                      controller: organizationController,
                      hintText: 'CDRRMO / BFP',
                      errorText: organizationError,
                      prefixIcon: Icons.account_balance_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          _buildLabel('Password'),
          SizedBox(height: AppSpacing.xs),
          _buildPasswordField(
            controller: passwordController,
            obscureText: obscurePassword,
            onToggle: onTogglePassword,
            errorText: passwordError,
          ),
          SizedBox(height: AppSpacing.lg),
          _buildLabel('Confirm password'),
          SizedBox(height: AppSpacing.xs),
          _buildPasswordField(
            controller: confirmPasswordController,
            obscureText: obscureConfirmPassword,
            onToggle: onToggleConfirmPassword,
            errorText: confirmPasswordError,
          ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? errorText,
    TextInputType? keyboardType,
    required IconData prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      style: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppTheme.neutralGray900,
      ),
      decoration: _inputDecoration(
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      style: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppTheme.neutralGray900,
      ),
      decoration: _inputDecoration(
        hintText: '••••••••',
        errorText: errorText,
        prefixIcon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            size: 22,
            color: AppTheme.neutralGray500,
          ),
          onPressed: onToggle,
          splashRadius: 20,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    String? errorText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.roboto(
        fontSize: 15,
        color: AppTheme.neutralGray400,
        fontWeight: FontWeight.w400,
      ),
      errorText: errorText,
      errorStyle: GoogleFonts.roboto(
        fontSize: 12,
        color: AppTheme.errorRed,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(prefixIcon, size: 22, color: AppTheme.neutralGray500),
      suffixIcon: suffixIcon,
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
    );
  }
}
