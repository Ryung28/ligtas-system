import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/src/generated/app_localizations.dart';
import 'package:mobile/src/core/utils/performance_utils.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart' hide AuthState;
import 'package:mobile/src/features/loans/presentation/screens/loan_history_screen.dart';
import 'package:mobile/src/features/dashboard/screens/dashboard_screen.dart';
import 'package:mobile/src/features_v2/loans/presentation/screens/active_loans_screen.dart';
import 'package:mobile/src/features/navigation/screens/main_screen.dart';
import 'package:mobile/src/features/scanner/widgets/scanner_view.dart';
import 'package:mobile/src/features/profile/screens/profile_screen.dart';
import 'package:mobile/src/features/profile/screens/personal_info_screen.dart';
import 'package:mobile/src/features/profile/screens/security_screen.dart';
import 'package:mobile/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:mobile/src/features/splash/screens/splash_screen_page.dart';
import 'package:mobile/src/features/intro/screens/modern_intro_cards.dart';
import 'package:mobile/src/features_v2/inventory/presentation/screens/inventory_screen.dart';
import 'package:mobile/src/features_v2/equipment_request/presentation/screens/request_equipment_screen.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/mission_cart_provider.dart';
import 'package:mobile/src/features/notifications/screens/notifications_screen.dart';
import 'package:mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/features/auth/domain/models/auth_state.dart';
import 'package:mobile/src/features/auth/domain/models/user_model.dart';
import 'package:mobile/src/features/auth/screens/login_screen.dart';
import 'package:mobile/src/features/auth/screens/register_screen.dart';
import 'package:mobile/src/features/notifications/data/services/user_notification_service.dart';
import 'package:mobile/src/features_v2/chat/presentation/screens/chat_screen.dart';
import 'package:mobile/src/features/scanner/presentation/screens/transaction_screen.dart';
import 'package:mobile/src/core/navigation/navigator_key.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/screens/analyst_terminal_screen.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/screens/activity_ledger_screen.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/screens/station_provisioning_screen.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/screens/logistical_queue_screen.dart';
import 'package:mobile/src/features/fast_dispatch/presentation/screens/fast_dispatch_screen.dart';
// AnalystHistoryScreen liquidated as per Anti-Monolith Protocol. Hub is now ActivityLedgerScreen for audits.

class ResQTrackApp extends ConsumerStatefulWidget {
  const ResQTrackApp({super.key});

  @override
  ConsumerState<ResQTrackApp> createState() => _ResQTrackAppState();
}

class _ResQTrackAppState extends ConsumerState<ResQTrackApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 🛡️ RE-ENFORCER: Reset 120Hz mode on resume as OS sometimes resets display profile
      PerformanceUtils.enforceHighRefreshRate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasValue) {
        final AuthState authState = next.value!;
        authState.whenOrNull(
          authenticated: (user) => UserNotificationService().handleAuthStateChange(user.id),
        );
      }
    });

    return NeumorphicTheme(
      theme: NeumorphicThemeData(
        baseColor: AppTheme.lightTheme.sentinel.surface,
        lightSource: LightSource.topLeft,
        depth: 4,
        intensity: 0.8,
      ),
      child: MaterialApp.router(
        title: 'ResQTrack',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        showPerformanceOverlay: false, // 🛡️ MISSION ACCOMPLISHED: 120Hz targets met.
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('tl'),
        ],
      ),
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
      // 🛡️ TACTICAL SHIELD: Prevent loops while auth is initializing or actively loading
      final authState = ref.read(authControllerProvider);
      final isActuallyLoading = authState.isLoading || 
          (authState.value?.maybeMap(loading: (_) => true, orElse: () => false) ?? false);
          
      if (isActuallyLoading && !authState.hasValue) return null;

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

      // 🛡️ UNIFIED LOGIN: Redirect after successful landing on public routes
      // 🛡️ SPLASH PROTECTION: Do not redirect if we are currently showing the splash screen
      if (isLoggedIn && isPublicRoute && state.uri.path != '/splash') {
        if (user.isActive) {
          if (user.role == 'loading') return null;
          return user.canEdit ? '/manager' : '/dashboard';
        }
      }

      // Logged in — only active users reach here (see currentUserProvider).
      if (isLoggedIn && !isPublicRoute) {
        if (user.isActive) {
          if (user.role == 'loading') return null;

          final onManagerRoute = state.uri.path.startsWith('/manager');

          if (!user.canEdit && onManagerRoute) return '/dashboard';
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
        redirect: (context, state) => '/login',
      ),
      GoRoute(
        path: '/denied',
        redirect: (context, state) => '/login',
      ),
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(),
        builder: (context, state, child) => MainScreen(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/history',
            builder: (context, state) => const LoanHistoryScreen(),
          ),
          GoRoute(
            path: '/manager',
            builder: (context, state) => const AnalystTerminalScreen(),
            routes: [
              GoRoute(
                path: 'queue',
                builder: (context, state) {
                  final id = state.uri.queryParameters['id'];
                  return LogisticalQueueScreen(initialAlertId: id);
                },
                routes: [
                  GoRoute(
                    path: 'triage/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      return LogisticalQueueScreen(triageAlertId: id);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'activity',
                builder: (context, state) => const ActivityLedgerScreen(),
              ),
              GoRoute(
                path: 'dispatch',
                builder: (context, state) => const FastDispatchScreen(),
              ),
              GoRoute(
                path: 'station/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final name = state.uri.queryParameters['name'] ?? 'Station';
                  // To be created next
                  return StationProvisioningScreen(stationId: id, stationName: name);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) {
              final id = state.uri.queryParameters['id'];
              return InventoryScreen(initialItemId: id);
            },
            routes: [
              GoRoute(
                path: 'triage/:itemId',
                builder: (context, state) {
                  final itemId = state.pathParameters['itemId'];
                  return InventoryScreen(triageItemId: itemId);
                },
              ),
              GoRoute(
                path: 'request',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra;
                  List<CartItem>? cartItems;
                  if (extra is InventoryItem) {
                    cartItems = [CartItem(item: extra, quantity: 1)];
                  } else if (extra is List<CartItem>) {
                    cartItems = extra;
                  }
                  return RequestEquipmentScreen(cartItems: cartItems);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const SettingsScreen(),
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
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/requests',
            builder: (context, state) => const ActiveLoansScreen(),
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
