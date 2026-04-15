import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/design_system/app_theme.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../auth/domain/models/user_model.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      final email = ref.read(currentUserProvider)?.email;
      
      if (email == null) {
        _showStatusSnackBar('Account Error: Unable to verify profile', AppTheme.errorRed);
        setState(() => _isLoading = false);
        return;
      }

      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: _currentPasswordController.text,
      );

      if (authResponse.user == null) {
        _showStatusSnackBar('Security Error: Incorrect password', AppTheme.errorRed);
        setState(() => _isLoading = false);
        return;
      }

      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      if (mounted) {
        _showStatusSnackBar('Success: Password updated successfully', AppTheme.successGreen);
        _clearForm();
        setState(() => _isChangingPassword = false);
      }
    } catch (e) {
      _showStatusSnackBar(ExceptionHandler.getDisplayMessage(e), AppTheme.errorRed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showStatusSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message, 
          style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).extension<LigtasColors>()!;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: sentinel.containerLowest,
      appBar: _buildAppBar(sentinel),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🛡️ SECURITY STATUS
              _buildSecurityStatusCard(sentinel, user).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
              
              const Gap(32),

              // 🔑 PASSWORD MANAGEMENT
              _buildPasswordSection(sentinel, user).animate().fadeIn(delay: 150.ms),
              
              const Gap(32),

              // 🚨 DANGER ZONE
              _buildDangerZone(sentinel).animate().fadeIn(delay: 250.ms),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(LigtasColors sentinel) {
    return AppBar(
      backgroundColor: sentinel.containerLowest,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: sentinel.navy),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'SECURITY',
        style: GoogleFonts.lexend(
          fontWeight: FontWeight.w800, 
          fontSize: 18, 
          color: sentinel.navy,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSecurityStatusCard(LigtasColors sentinel, UserModel? user) {
    final isSocial = !(user?.canChangePassword ?? true);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: sentinel.navy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: sentinel.tactile.card,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSocial ? Icons.verified_user_rounded : Icons.lock_outline_rounded,
              color: isSocial ? AppTheme.successGreen : Colors.white,
              size: 28,
            ),
          ),
          const Gap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSocial ? 'Google Protected' : 'Account Secured',
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const Gap(4),
                Text(
                  isSocial 
                    ? 'Authentication managed by Google'
                    : 'Your password is saved and encrypted',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection(LigtasColors sentinel, UserModel? user) {
    if (!(user?.canChangePassword ?? true)) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACCOUNT CREDENTIALS',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: sentinel.navy.withOpacity(0.4),
              ),
            ),
            if (!_isChangingPassword)
              TextButton(
                onPressed: () => setState(() => _isChangingPassword = true),
                child: Text(
                  'Change Password',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w600, 
                    fontSize: 12,
                    color: sentinel.navy,
                  ),
                ),
              ),
          ],
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: sentinel.tactile.card,
            border: Border.all(color: sentinel.navy.withOpacity(0.05)),
          ),
          child: _isChangingPassword ? _buildChangePasswordForm(sentinel) : _buildPasswordStatus(sentinel),
        ),
      ],
    );
  }

  Widget _buildPasswordStatus(LigtasColors sentinel) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: sentinel.navy.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.password_rounded, color: sentinel.navy, size: 22),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status: Secured',
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: sentinel.navy,
                ),
              ),
              const Gap(4),
              Text(
                'Password was last verified today',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: sentinel.navy.withOpacity(0.4),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 20),
      ],
    );
  }

  Widget _buildChangePasswordForm(LigtasColors sentinel) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            sentinel: sentinel,
            controller: _currentPasswordController,
            label: 'Current Password',
            obscureText: _obscureCurrentPassword,
            onToggle: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
            validator: (v) => v == null || v.isEmpty ? 'Current password is required' : null,
          ),
          const Gap(24),
          _buildInputField(
            sentinel: sentinel,
            controller: _newPasswordController,
            label: 'New Password',
            obscureText: _obscureNewPassword,
            onToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
          ),
          const Gap(24),
          _buildInputField(
            sentinel: sentinel,
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
            obscureText: _obscureConfirmPassword,
            onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            validator: (v) => (v != _newPasswordController.text) ? 'Passwords do not match' : null,
          ),
          const Gap(32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _isLoading ? null : () => setState(() => _isChangingPassword = false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Cancel', style: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: sentinel.navy.withOpacity(0.5))),
                ),
              ),
              const Gap(12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sentinel.navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Update Password', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required LigtasColors sentinel,
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: sentinel.navy.withOpacity(0.5),
          ),
        ),
        const Gap(8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: sentinel.containerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: sentinel.navy.withOpacity(0.05))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: sentinel.navy.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: sentinel.navy.withOpacity(0.2), width: 1.5)),
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: sentinel.navy.withOpacity(0.3)),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone(LigtasColors sentinel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DANGER ZONE',
          style: GoogleFonts.lexend(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: AppTheme.errorRed.withOpacity(0.6),
          ),
        ),
        const Gap(12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.errorRed.withOpacity(0.05)),
            boxShadow: sentinel.tactile.card,
          ),
          child: _buildSimpleTile(
            sentinel: sentinel,
            icon: Icons.logout_rounded,
            iconColor: AppTheme.errorRed,
            title: 'Sign Out',
            subtitle: 'Sign out and clear local cached data',
            onTap: () => _showSignOutDialog(sentinel),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleTile({
    required LigtasColors sentinel,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w600, color: sentinel.navy),
                  ),
                  const Gap(4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: sentinel.navy.withOpacity(0.4), fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: sentinel.navy.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(LigtasColors sentinel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Sign Out?', style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Text(
          'Are you sure you want to sign out? This will clear your local inventory cache.',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400, fontSize: 14, color: sentinel.navy.withOpacity(0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: sentinel.navy.withOpacity(0.4))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authControllerProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Sign Out', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}


