import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design_system/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../models/auth_state.dart';
import '../widgets/login_background_pattern.dart';
import '../../../core/design_system/widgets/atmospheric_background.dart';

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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
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
          authenticated: (user) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Account Provisioned Successfully'),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(20),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white, 
                                padding: const EdgeInsets.all(12),
                                elevation: 2,
                                shadowColor: Colors.black12,
                              ),
                            ).animate().fadeIn().slideX(begin: -0.2),
                            
                            const Gap(24),
                            
                            Text(
                              'Create Personnel\nAccount',
                              style: GoogleFonts.outfit(
                                fontSize: isSmallScreen ? 28 : 32,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                height: 1.1,
                                letterSpacing: -1.0,
                              ),
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                            
                            const Gap(12),
                            
                            Text(
                              'Register to access the LIGTAS Operational Network.',
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 14 : 15,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF64748B),
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                            
                            const Gap(40),

                            Animate(
                              key: ValueKey(_shakeCount),
                              effects: _shakeCount > 0 ? [ShakeEffect(duration: 400.ms, hz: 4, offset: const Offset(8, 0))] : [],
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03), 
                                      blurRadius: 20, 
                                      offset: const Offset(0, 10)
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                                ),
                                child: Form(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  child: Column(
                                    children: [
                                      _buildInputField(
                                        controller: _nameController,
                                        label: 'Full Name',
                                        hint: 'Enter your given name',
                                        icon: Icons.person_outline_rounded,
                                        validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                                      ),
                                      
                                      const Gap(20),
                                      
                                      _buildInputField(
                                        controller: _emailController,
                                        label: 'Email Address',
                                        hint: 'official@cdrrmo.ph',
                                        icon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Email is required';
                                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                          if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                                          return null;
                                        },
                                      ),
                                      
                                      const Gap(20),
                                      
                                      _buildInputField(
                                        controller: _passwordController,
                                        label: 'Password',
                                        hint: 'Min. 6 characters',
                                        icon: Icons.lock_outline_rounded,
                                        isPassword: true,
                                        isVisible: _isPasswordVisible,
                                        onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                        validator: (value) => value == null || value.length < 6 ? 'Min 6 characters' : null,
                                      ),
                                      
                                      const Gap(20),
                                      
                                      _buildInputField(
                                        controller: _confirmPasswordController,
                                        label: 'Confirm Password',
                                        hint: 'Repeat your password',
                                        icon: Icons.lock_reset_rounded,
                                        isPassword: true,
                                        isVisible: _isPasswordVisible,
                                        validator: (value) {
                                          if (value != _passwordController.text) return 'Mismatch';
                                          return null;
                                        },
                                      ),
                                      
                                      const Gap(32),

                                      SizedBox(
                                        width: double.infinity,
                                        height: 58,
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
                                              : Text('REGISTER ACCOUNT', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                            
                            const Spacer(),
                            
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text("Already have an account? ", style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13)),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Text('Sign In Here', style: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 13)),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 800.ms),
                            const Gap(40),
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
          child: Text(label.toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 1.0)),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isVisible,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
            suffixIcon: isPassword && onVisibilityToggle != null
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
