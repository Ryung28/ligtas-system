import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/widgets/tactical_notice.dart';
import 'package:mobile/src/features/auth/presentation/controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  int _shakeCount = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          );
    } else {
      setState(() => _shakeCount++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).extension<LigtasColors>()!;

    // ── AUTHENTICATION LIFECYCLE LISTENER ──
    ref.listen(authControllerProvider, (previous, next) {
      next.whenData((authState) {
        authState.mapOrNull(
          authenticated: (user) {
            TacticalNotice.show(
              context,
              message: 'Verification email sent. Please check your inbox.',
              type: NoticeType.success,
            );
            context.go('/login');
          },
          error: (state) {
            TacticalNotice.show(
              context,
              message: state.message,
              type: NoticeType.error,
            );
          },
        );
      });
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.maybeWhen(
      data: (s) => s.maybeWhen(loading: () => true, orElse: () => false),
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: sentinel.containerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: sentinel.navy, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(20),
                
                // ── BRANDING HUD ──
                Center(
                  child: Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: sentinel.tactile.card,
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Image.asset('assets/cdrrmo_logo.png', height: 60),
                      ),
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                const Gap(32),
                
                Text(
                  'Create Account',
                  style: GoogleFonts.lexend(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: sentinel.navy,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1),
                
                const Gap(12),
                
                Text(
                  'Register your official credentials to access tactical logistics.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: sentinel.navy.withOpacity(0.5),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                
                const Gap(40),

                // ── REGISTRATION FORM ──
                Animate(
                  key: ValueKey(_shakeCount),
                  effects: _shakeCount > 0 ? [ShakeEffect(duration: 400.ms)] : [],
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: sentinel.tactile.card,
                      border: Border.all(color: sentinel.navy.withOpacity(0.05)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInputField(
                            sentinel: sentinel,
                            controller: _nameController,
                            label: 'OPERATOR FULL NAME',
                            hint: 'Enter legal name',
                            icon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                            autofillHints: [AutofillHints.name],
                            validator: (value) => (value == null || value.trim().isEmpty) ? 'Name is required' : null,
                          ),
                          const Gap(24),
                          _buildInputField(
                            sentinel: sentinel,
                            controller: _emailController,
                            label: 'OFFICIAL EMAIL',
                            hint: 'your@email.com',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: [AutofillHints.email],
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Email is required';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const Gap(24),
                          _buildInputField(
                            sentinel: sentinel,
                            controller: _passwordController,
                            label: 'SECURE PASSWORD',
                            hint: 'Min 6 characters',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            isVisible: _isPasswordVisible,
                            onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            textInputAction: TextInputAction.next,
                            autofillHints: [AutofillHints.newPassword],
                            validator: (value) => (value == null || value.length < 6) ? 'Password too short' : null,
                          ),
                          const Gap(24),
                          _buildInputField(
                            sentinel: sentinel,
                            controller: _confirmPasswordController,
                            label: 'CONFIRM PASSWORD',
                            hint: 'Sync verification',
                            icon: Icons.security_rounded,
                            isPassword: true,
                            isVisible: _isPasswordVisible, // Visibility Sync
                            onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            validator: (value) => value != _passwordController.text ? 'Passwords mismatch' : null,
                          ),
                          
                          const Gap(32),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sentinel.navy,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'INITIATE REGISTRATION',
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                const Gap(32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Returning responder?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: sentinel.navy.withOpacity(0.4),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'SIGN IN',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: sentinel.navy,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Gap(40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required LigtasColors sentinel,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
    Iterable<String>? autofillHints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: sentinel.navy.withOpacity(0.5),
            letterSpacing: 1.0,
          ),
        ),
        const Gap(8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isVisible,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          autofillHints: autofillHints,
          autocorrect: false,
          enableSuggestions: !isPassword,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: sentinel.navy,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(color: sentinel.navy.withOpacity(0.2), fontWeight: FontWeight.w400),
            prefixIcon: Icon(icon, color: sentinel.navy.withOpacity(0.3), size: 18),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: sentinel.navy.withOpacity(0.3), size: 18),
                    onPressed: onToggle,
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: sentinel.navy.withOpacity(0.12))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: sentinel.navy, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.errorRed, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.errorRed, width: 1.5)),
            errorStyle: GoogleFonts.plusJakartaSans(color: AppTheme.errorRed, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
