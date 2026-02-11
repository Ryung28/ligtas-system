import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/branding.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/app_spacing.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_header.dart';
import '../widgets/register_form_card.dart';
import '../widgets/register_actions.dart';

/// Register screen: premium, simple layout
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _organizationController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _toggleConfirmPassword() {
    setState(() => _obscureConfirm = !_obscureConfirm);
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    String? nameError;
    String? emailError;
    String? passwordError;
    String? confirmError;

    if (name.isEmpty) {
      nameError = 'Enter your full name';
    }

    if (email.isEmpty) {
      emailError = 'Enter your email';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emailError = 'Enter a valid email';
    }

    if (password.isEmpty) {
      passwordError = 'Create a password';
    } else if (password.length < 6) {
      passwordError = 'Use at least 6 characters';
    }

    if (confirm.isEmpty) {
      confirmError = 'Confirm your password';
    } else if (confirm != password) {
      confirmError = 'Passwords do not match';
    }

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmError = confirmError;
    });

    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
    });

    await ref.read(authProvider.notifier).signUp(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      organization: _organizationController.text.trim(),
    );

    final authState = ref.read(authProvider);
    
    if (authState.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } else if (authState.hasValue && authState.value == null && mounted) {
      // Success but no session (Awaiting email confirmation)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please check your email to confirm your account.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Professional listener for successful authentication
    ref.listen(authProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        context.go('/dashboard');
      }
    });

    final isLoading = ref.watch(authLoadingProvider);
    final isCompact = MediaQuery.sizeOf(context).height < 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.neutralGray50,
              AppTheme.neutralGray100.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  Gap(isCompact ? 20 : 36),
                  const LoginHeader(compact: true),
                  Gap(isCompact ? 20 : 32),
                  RegisterFormCard(
                    nameController: _nameController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    organizationController: _organizationController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    obscurePassword: _obscurePassword,
                    obscureConfirmPassword: _obscureConfirm,
                    onTogglePassword: _togglePassword,
                    onToggleConfirmPassword: _toggleConfirmPassword,
                    nameError: _nameError,
                    emailError: _emailError,
                    passwordError: _passwordError,
                    confirmPasswordError: _confirmError,
                    enabled: !isLoading,
                  ),
                  const Gap(24),
                  RegisterActions(
                    onRegister: _submit,
                    onSignIn: () => context.go('/login'),
                    isLoading: isLoading,
                  ),
                  const Gap(20),
                  Text(
                    Branding.tagline,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.neutralGray500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
