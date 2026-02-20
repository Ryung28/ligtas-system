import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../models/auth_state.dart';
import '../widgets/login_background_pattern.dart';
import '../../../core/design_system/widgets/atmospheric_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  
  // For the shake effect on validation error
  int _shakeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email') ?? '';
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (mounted) {
      setState(() {
        _rememberMe = rememberMe;
        if (_rememberMe && savedEmail.isNotEmpty) {
          _emailController.text = savedEmail;
        }
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_email', _emailController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('remembered_email');
      await prefs.setBool('remember_me', false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await _saveCredentials();
      ref.read(authControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    } else {
      setState(() {
        _shakeCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      next.whenData((authState) {
        authState.mapOrNull(
          authenticated: (state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.accessGranted(state.user.displayName ?? 'Personnel')),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppTheme.successGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          error: (state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 380;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AtmosphericBackground(), 
          const LoginBackgroundPattern().animate().fadeIn(duration: 800.ms),
          
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: size.width,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          children: [
                            const Spacer(flex: 2),
                            
                            // ── Logo Header ──
                            Hero(
                              tag: 'app_logo',
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.asset(
                                    'assets/cdrrmo_logo.png',
                                    width: isSmallScreen ? 80 : 95,
                                    height: isSmallScreen ? 80 : 95,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 95,
                                      height: 95,
                                      color: const Color(0xFFF1F5F9),
                                      child: const Icon(Icons.shield_rounded, size: 40, color: AppTheme.primaryBlue),
                                    ),
                                  ),
                                ),
                              ),
                            ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                            
                            const Gap(24),
                            
                            Text(
                              context.l10n.appTitle,
                              style: GoogleFonts.outfit(
                                fontSize: isSmallScreen ? 22 : 26,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                            
                            const Gap(8),
                            
                            Text(
                              context.l10n.loginGateway,
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 11 : 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                                letterSpacing: 1.5,
                              ),
                            ).animate().fadeIn(delay: 400.ms),
                            
                            const Gap(40),

                            // ── Login Card with Shake Interaction ──
                            Animate(
                              key: ValueKey(_shakeCount),
                              effects: _shakeCount > 0 ? [ShakeEffect(duration: 400.ms, hz: 4, offset: const Offset(8, 0))] : [],
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 20 : 24, 
                                  vertical: isSmallScreen ? 30 : 40
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                                ),
                                child: Form(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  child: Column(
                                    children: [
                                      _buildInputField(
                                        controller: _emailController,
                                        label: context.l10n.emailLabel,
                                        hint: context.l10n.emailHint,
                                        icon: Icons.email_rounded,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Email is required';
                                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                          if (!emailRegex.hasMatch(value)) return 'Valid email required';
                                          return null;
                                        },
                                      ),
                                      
                                      const Gap(20),
                                      
                                      _buildInputField(
                                        controller: _passwordController,
                                        label: context.l10n.passwordLabel,
                                        hint: context.l10n.passwordHint,
                                        icon: Icons.lock_rounded,
                                        isPassword: true,
                                        isVisible: _isPasswordVisible,
                                        onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                        validator: (value) => (value == null || value.length < 6) ? 'Min 6 characters' : null,
                                      ),
                                      
                                      const Gap(16),

                                      // ── Remember Me Checkbox ──
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                              activeColor: AppTheme.primaryBlue,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                              side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                                            ),
                                          ),
                                          const Gap(10),
                                          GestureDetector(
                                            onTap: () => setState(() => _rememberMe = !_rememberMe),
                                            child: Text(
                                              'Stay signed in on this device',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ).animate().fadeIn(delay: 650.ms),
                                      
                                      const Gap(32),

                                      // Login Action
                                      SizedBox(
                                        width: double.infinity,
                                        height: AppSizing.buttonXl,
                                        child: ElevatedButton(
                                          onPressed: isLoading ? null : _submit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryBlue,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          ),
                                          child: isLoading
                                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                              : Text(context.l10n.signInButton, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                        ),
                                      ),

                                      const Gap(24),
                                      
                                      Row(
                                        children: [
                                          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text('OR', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
                                          ),
                                          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                                        ],
                                      ),

                                      const Gap(24),

                                      // Google Action
                                      SizedBox(
                                        width: double.infinity,
                                        height: AppSizing.buttonXl,
                                        child: OutlinedButton(
                                          onPressed: isLoading ? null : () => ref.read(authControllerProvider.notifier).signInWithGoogle(_rememberMe),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            backgroundColor: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: 'https://img.icons8.com/color/48/000000/google-logo.png',
                                                height: 24,
                                                memCacheHeight: 48,
                                                memCacheWidth: 48,
                                                placeholder: (context, url) => const SizedBox(width: 24, height: 24),
                                                errorWidget: (context, url, error) => const Icon(Icons.g_mobiledata, size: 30),
                                              ),
                                              const Gap(12),
                                              Flexible(
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    context.l10n.googleSignInButton,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w700,
                                                      color: const Color(0xFF1E293B),
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.1),
                            
                            const Spacer(flex: 1),
                            
                            Column(
                              children: [
                                Text('Need assistance?', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13)),
                                const Gap(4),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text('CONTACT IT SUPPORT', style: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                                const Gap(24),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text("Don't have an account? ", style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13)),
                                    GestureDetector(
                                      onTap: () => context.push('/register'),
                                      child: Text('Create Account', style: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 13)),
                                    ),
                                  ],
                                ),
                                const Gap(32),
                                Text('© 2026 CDRRMO RESOURCE NETWORK', style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                              ],
                            ).animate().fadeIn(delay: 800.ms),
                            
                            const Gap(20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label.toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF64748B), letterSpacing: 1.0)),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isVisible,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: const Color(0xFF94A3B8), size: 20),
                    onPressed: onVisibilityToggle,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppTheme.errorRed, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppTheme.errorRed, width: 2)),
            errorStyle: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
