import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/src/generated/app_localizations.dart';

import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features/dashboard/screens/dashboard_screen.dart';
import 'package:mobile/src/features_v2/loans/presentation/screens/active_loans_screen.dart';
// import 'package:mobile/src/features/loans/screens/create_loan_screen.dart'; // Missing
import 'package:mobile/src/features/navigation/screens/main_screen.dart';
import 'package:mobile/src/features/scanner/widgets/scanner_view.dart';
import 'package:mobile/src/features/profile/screens/profile_screen.dart';
import 'package:mobile/src/features/profile/screens/personal_info_screen.dart';
import 'package:mobile/src/features/profile/screens/security_screen.dart';

import 'package:mobile/src/features/splash/screens/splash_screen_page.dart';
import 'package:mobile/src/features/intro/screens/modern_intro_cards.dart';
import 'package:mobile/src/features_v2/inventory/presentation/screens/inventory_screen.dart';
import 'package:mobile/src/features/notifications/screens/notifications_screen.dart';
import 'package:mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/features/auth/domain/models/auth_state.dart';
import 'package:mobile/src/features/auth/domain/models/user_model.dart';
import 'package:mobile/src/features/auth/screens/login_screen.dart';
import 'package:mobile/src/features/auth/screens/register_screen.dart';
import 'package:mobile/src/features/auth/screens/pending_approval_screen.dart';
import 'package:mobile/src/features/auth/screens/access_denied_screen.dart';
import 'package:mobile/src/features/notifications/data/services/user_notification_service.dart';
// import 'package:mobile/src/features/loans/screens/requests_screen.dart'; // Missing
import 'package:mobile/src/features_v2/chat/presentation/screens/chat_screen.dart';
import 'package:mobile/src/features/scanner/presentation/screens/transaction_screen.dart';
import 'package:mobile/src/core/navigation/navigator_key.dart';

class LigtasApp extends ConsumerWidget {
  const LigtasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // RouterProvider now maintains stability across auth changes
    final router = ref.watch(routerProvider);

    // 🛡️ GLOBAL NOTIFICATION ORCHESTRATOR
    // Listen to Auth State changes globally to trigger device registration.
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasValue) {
        final AuthState authState = next.value!;
        authState.whenOrNull(
          authenticated: (user) => UserNotificationService().handleAuthStateChange(user.id),
          pendingApproval: (user) => UserNotificationService().handleAuthStateChange(user.id),
        );
      }
    });


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
  final listenable = RiverpodRouterRefreshListenable(ref);
  
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: listenable,
    redirect: (context, state) {
      // 🛡️ TACTICAL SHIELD: Prevent loops while auth is initializing
      final authState = ref.read(authControllerProvider);
      if (authState.isLoading && !authState.hasValue) return null;

      final user = ref.read(currentUserProvider);
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
        path: '/',
        redirect: (context, state) => '/splash',
      ),
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
        builder: (context, state) => const PendingApprovalScreen(),
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
                  // return CreateLoanScreen(scannedItemId: scannedItemId);
                  return const ActiveLoansScreen(); // Redirect to v2 ActiveLoans
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
            routes: [
              GoRoute(
                path: 'personal-info',
                builder: (context, state) => const PersonalInfoScreen(),
              ),
              GoRoute(
                path: 'security',
                builder: (context, state) => const SecurityScreen(),
              ),
            ],
          ),

          GoRoute(
            path: '/requests',
            // builder: (context, state) => const RequestsScreen(),
            builder: (context, state) => const ActiveLoansScreen(), // Requests are now a tab in v2
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
      GoRoute(
        path: '/chat/:roomId',
        pageBuilder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          final title = state.uri.queryParameters['title'] ?? 'Chat';
          
          return CustomTransitionPage(
            key: state.pageKey,
            child: ChatScreen(
              roomId: roomId, 
              title: title,
            ),
            transitionDuration: const Duration(milliseconds: 350),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuint,
                    ),
                  ),
                  child: child,
                ),
              );
            },
          );
        },
      ),
    ],
  );
});

/// 🛡️ TACTICAL BRIDGE: Connects Riverpod Auth State to GoRouter's Refresh Logic
class RiverpodRouterRefreshListenable extends ChangeNotifier {
  RiverpodRouterRefreshListenable(Ref ref) {
    _subscription = ref.listen(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AsyncValue<AuthState>> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

