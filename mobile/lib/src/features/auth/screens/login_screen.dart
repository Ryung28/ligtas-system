import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import '../../../core/config/branding.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/app_spacing.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form_card.dart';
import '../widgets/login_actions.dart';

/// Login screen: professional, simple, premium layout
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? emailError;
    String? passwordError;

    if (email.isEmpty) {
      emailError = 'Enter your email';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emailError = 'Enter a valid email';
    }

    if (password.isEmpty) {
      passwordError = 'Enter your password';
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    return emailError == null && passwordError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    await ref.read(authProvider.notifier).signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    final authState = ref.read(authProvider);
    if (authState.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setupAuthListener() {
    ref.listen(authProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        context.go('/dashboard');
      }
    });
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
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gap(isCompact ? 24 : 48),
                  const LoginHeader(compact: false),
                  Gap(isCompact ? 24 : 40),
                  Form(
                    key: _formKey,
                    child: LoginFormCard(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      onTogglePassword: _togglePassword,
                      emailError: _emailError,
                      passwordError: _passwordError,
                      enabled: !isLoading,
                    ),
                  ),
                  const Gap(24),
                  LoginActions(
                    onLogin: _submit,
                    onForgotPassword: () {
                      // TODO: Forgot password flow
                    },
                    isLoading: isLoading,
                  ),
                  const Gap(32),
                  TextButton(
                    onPressed: isLoading ? null : () => context.go('/register'),
                    child: Text(
                      "Don't have an account? Create one",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Gap(20),
                  // Skip button for development
                  TextButton(
                    onPressed: isLoading ? null : () => context.go('/dashboard'),
                    child: Text(
                      "Skip to Dashboard (Dev Mode)",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.neutralGray600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Text(
                    Branding.tagline,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.neutralGray500,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
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
