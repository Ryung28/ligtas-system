import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/src/generated/app_localizations.dart';

import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features/dashboard/screens/dashboard_screen.dart';
import 'package:mobile/src/features/loans/screens/active_loans_screen.dart';
import 'package:mobile/src/features/loans/screens/create_loan_screen.dart';
import 'package:mobile/src/features/navigation/screens/main_screen.dart';
import 'package:mobile/src/features/scanner/widgets/scanner_view.dart';
import 'package:mobile/src/features/profile/screens/profile_screen.dart';
import 'package:mobile/src/features/splash/screens/splash_screen_page.dart';
import 'package:mobile/src/features/intro/screens/modern_intro_cards.dart';
import 'package:mobile/src/features/inventory/screens/inventory_screen.dart';
import 'package:mobile/src/features/notifications/screens/notifications_screen.dart';
import 'package:mobile/src/features/auth/screens/login_screen.dart';
import 'package:mobile/src/features/auth/screens/register_screen.dart';
import 'package:mobile/src/features/auth/screens/pending_access_screen.dart';
import 'package:mobile/src/features/auth/screens/access_denied_screen.dart';
import 'package:mobile/src/features/auth/providers/auth_provider.dart';
import 'package:mobile/src/features/loans/screens/requests_screen.dart';
import 'package:mobile/src/features/scanner/models/qr_payload.dart';
import 'package:mobile/src/features/scanner/widgets/scan_result_sheet.dart';

class LigtasApp extends ConsumerWidget {
  const LigtasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // RouterProvider now maintains stability across auth changes
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'LIGTAS Mobile',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('tl'), // Tagalog
      ],
    );
  }
}

// Ensure GoRouter is not rebuilt on auth state changes
// by reading the provider inside the closure and using refreshListenable
final routerProvider = Provider<GoRouter>((ref) {
  // Use read to avoid unnecessary rebuilds of the router instantiation itself
  final authNotifier = ref.read(authProvider.notifier);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    redirect: (context, state) {
      // Access the value directly from the provider without watching it
      // This allows redirect to be called by refreshListenable
      final authState = ref.read(authProvider);
      final user = authState.value;
      final isLoggedIn = user != null;
      final isPublicRoute = state.uri.path == '/login' || 
                           state.uri.path == '/register' || 
                           state.uri.path == '/splash' ||
                           state.uri.path == '/intro';

      // Not logged in - redirect to login
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // Logged in but on public route
      if (isLoggedIn && isPublicRoute) {
        // Check user status and redirect accordingly
        if (user.isPending) {
          return '/pending';
        } else if (user.isSuspended) {
          return '/denied';
        } else if (user.isActive) {
          return '/dashboard';
        }
      }

      // Logged in - check status for protected routes
      if (isLoggedIn && !isPublicRoute) {
        final isStatusRoute = state.uri.path == '/pending' || 
                             state.uri.path == '/denied';
        
        if (user.isPending && state.uri.path != '/pending') {
          return '/pending';
        }
        
        if (user.isSuspended && state.uri.path != '/denied') {
          return '/denied';
        }
        
        // User is active but on status route - redirect to dashboard
        if (user.isActive && isStatusRoute) {
          return '/dashboard';
        }
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreenPage(),
      ),
      GoRoute(
        path: '/intro',
        builder: (context, state) => const ModernIntroCards(),
      ),
      GoRoute(
        path: '/login', 
        builder: (context, state) => const LoginScreen()
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/pending',
        builder: (context, state) => const PendingAccessScreen(),
      ),
      GoRoute(
        path: '/denied',
        builder: (context, state) => const AccessDeniedScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/loans',
            builder: (context, state) => const ActiveLoansScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  final scannedItemId = state.uri.queryParameters['scannedItemId'];
                  return CreateLoanScreen(scannedItemId: scannedItemId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/requests',
            builder: (context, state) => const RequestsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => ScannerView(
          onQrCodeDetected: (qrCode) {
            Navigator.of(context).pop(qrCode);
          },
          overlayText: 'Scan item QR code',
        ),
      ),
      GoRoute(
        path: '/transaction',
        builder: (context, state) => const TransactionScreen(),
      ),
    ],
  );
});

// Utility to bridge Riverpod Stream to GoRouter's Listenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Transaction Screen - handles QR code processing
class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    // Process QR code immediately on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processQrCode();
    });
  }

  void _processQrCode() {
    final qrCode = GoRouterState.of(context).uri.queryParameters['qrCode'];
    
    if (qrCode == null || qrCode.isEmpty) {
      _showError('No QR code data received');
      return;
    }

    // Use the robust parser from models
    final payload = LigtasQrPayload.tryParse(qrCode);
    
    if (payload == null) {
      _showError('Invalid QR Code. Please scan a LIGTAS equipment label.');
      return;
    }

    // Show the actual premium confirmation sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => ScanResultSheet(payload: payload),
    ).then((success) {
      // After sheet closes, go back to dashboard
      if (mounted) {
        context.go('/dashboard');
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    // Navigate back after showing error
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) context.go('/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
