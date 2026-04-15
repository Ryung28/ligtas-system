import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/widgets/tactical_notice.dart';
import 'package:mobile/src/features/auth/presentation/controllers/auth_controller.dart';

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
  int _shakeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('remembered_email') ?? '';
      }
    });
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
      setState(() => _shakeCount++);
    }
  }

  // 🛡️ TACTICAL GUARD: Separate Google trigger to prevent UI focus jitter
  void _submitWithGoogle() async {
    final auth = ref.read(authControllerProvider);
    if (auth.isLoading) return; // Prevent double-triggering

    debugPrint('📡 [Login-UI] Dispatching Google Handshake...');
    await ref.read(authControllerProvider.notifier).signInWithGoogle(_rememberMe);
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).extension<LigtasColors>()!;
    
    // ── AUTHENTICATION LIFECYCLE LISTENER ──
    ref.listen(authControllerProvider, (previous, next) {
      next.whenData((authState) {
        authState.mapOrNull(
          authenticated: (user) {
            // 🛡️ ARCHITECT'S NOTE: Manual context.go('/') removed. 
            // We now rely on GoRouter behavior to trigger redirects automatically 
            // via the authRepository/authController subscription defined in app.dart.
          },
          pendingApproval: (user) {
            context.push('/pending-approval');
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
      loading: () => true, // Handle Riverpod's native loading state
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: sentinel.containerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(40),
                
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

                const Gap(24),
                
                // ── SYSTEM TITLE ──
                Column(
                  children: [
                    Text(
                      'LIGTAS',
                      style: GoogleFonts.lexend(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: sentinel.navy,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'LOGISTICS COMMAND',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sentinel.navy.withOpacity(0.4),
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                const Gap(40),

                // ── AUTHENTICATION CARD ──
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
                            controller: _emailController,
                            label: 'EMAIL ADDRESS',
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
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            isVisible: _isPasswordVisible,
                            onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            autofillHints: [AutofillHints.password],
                            validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
                          ),
                          const Gap(20),
                          
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                  activeColor: sentinel.navy,
                                  side: BorderSide(color: sentinel.navy.withOpacity(0.2)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                              const Gap(12),
                              Text(
                                'Remember this device',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: sentinel.navy.withOpacity(0.5),
                                ),
                              ),
                            ],
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
                                      'SIGN IN',
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                            ),
                          ),

                          const Gap(24),

                          Row(
                            children: [
                              Expanded(child: Divider(color: sentinel.navy.withOpacity(0.05))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: GoogleFonts.lexend(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: sentinel.navy.withOpacity(0.2),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: sentinel.navy.withOpacity(0.05))),
                            ],
                          ),

                          const Gap(24),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: isLoading ? null : _submitWithGoogle,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: sentinel.navy.withOpacity(0.05)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isLoading)
                                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  else ...[
                                    Image.asset('assets/gmail_logo.png', height: 18),
                                    const Gap(12),
                                    Text(
                                      'Sign in with Gmail',
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: sentinel.navy,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                const Gap(24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: () => context.go('/dashboard'),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_rounded, size: 20, color: sentinel.navy.withOpacity(0.4)),
                        const Gap(12),
                        Text(
                          'CONTINUE AS GUEST',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sentinel.navy.withOpacity(0.4),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ),

                const Gap(32),

                Column(
                  children: [
                    Text(
                      'SYSTEM OS V1.0.0',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: sentinel.navy.withOpacity(0.2),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Gap(12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Need an account?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: sentinel.navy.withOpacity(0.4),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: Text(
                            'REGISTER',
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: sentinel.navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
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
