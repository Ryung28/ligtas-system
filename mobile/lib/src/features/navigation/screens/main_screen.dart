import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/design_system/widgets/app_toast.dart';
import '../../scanner/widgets/scanner_view.dart';
import '../../scanner/models/qr_payload.dart';
import '../../scanner/widgets/scan_result_sheet.dart';
import '../../../core/design_system/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/navigation_provider.dart';
import '../../../core/design_system/widgets/offline_indicator.dart';
import '../../notifications/data/services/user_notification_service.dart';
import '../widgets/comms_capsule.dart';
import '../widgets/comms_drawer.dart';
import '../providers/comms_capsule_provider.dart';
import '../../auth/presentation/providers/auth_providers.dart';

/// 🛡️ THE MASTER TACTICAL SCHEME
/// Defines the intention and destination for the Adaptive Shell.
class _NavAction {
  final String label;
  final IconData icon;
  final String path;

  const _NavAction({
    required this.label,
    required this.icon,
    required this.path,
  });
}

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;
  final String location;

  const MainScreen({super.key, required this.child, required this.location});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _isDockVisible = true;
  Timer? _hideTimer;
  StreamSubscription? _notifSubscription;
  DateTime? _lastBackPressed;
  static const _exitConfirmationDuration = Duration(seconds: 2);
  
  @override
  void initState() {
    super.initState();
    _startHideTimer();
    
    // 📡 Navigation Bridge: Listen for tactical notification deep-links
    _notifSubscription = UserNotificationService.navigationStream.listen((path) {
      if (mounted) {
        debugPrint('🧭 Navigation Bridge: Jumping to $path');
        context.go(path);
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _notifSubscription?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _isDockVisible) {
        setState(() => _isDockVisible = false);
      }
    });
  }

  void _handleActivity({bool force = false}) {
    // Senior Dev Logic: If navigation is suppressed (e.g. detailed view open), 
    // we ignore activity triggers unless forced (e.g. by suppression exit).
    final isSuppressed = ref.read(isDockSuppressedProvider);
    if (isSuppressed && !force) return;

    if (!_isDockVisible) {
      setState(() => _isDockVisible = true);
    }
    _startHideTimer();
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScannerView(
          onQrCodeDetected: (qrCode) {
            Navigator.of(context).pop();
            _handleScannedCode(qrCode);
          },
          overlayText: 'Scan CDRRMO equipment label',
        ),
      ),
    );
  }

  void _handleScannedCode(String qrCode) async {
    final payload = LigtasQrPayload.tryParse(qrCode);
    
    if (payload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR Code. Please scan a LIGTAS label.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Suppress dock while showing result sheet
    ref.read(isDockSuppressedProvider.notifier).state = true;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScanResultSheet(payload: payload),
    );
    
    ref.read(isDockSuppressedProvider.notifier).state = false;
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleActivity(); // Reset timer on route change
  }

  static const _taskChannel = MethodChannel('com.example.ligtas_system/task');

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final user = ref.watch(currentUserProvider);
    final isManager = user?.canEdit ?? false;
    final isDockSuppressed = ref.watch(isDockSuppressedProvider);
    final isKeyboardVisible = viewInsets.bottom > 0;
    
    // 🛰️ Dock Awareness: Proactively wake the dock when suppression ends or keyboard hides
    ref.listen(isDockSuppressedProvider, (previous, next) {
      if (previous == true && next == false) {
        // FORCE the dock to wake up immediately when suppression ends
        _handleActivity(force: true);
      }
    });

    final showDock = _isDockVisible && !isKeyboardVisible && !isDockSuppressed;
    final isCommsDrawerOpen = ref.watch(commsDrawerStateProvider);

    // 🗺️ TACTICAL MANIFEST: Provision items based on Role
    final List<_NavAction> actions = isManager ? [
      const _NavAction(label: 'Terminal', icon: Icons.grid_view_rounded, path: '/manager'),
      const _NavAction(label: 'Queue', icon: Icons.assignment_late_rounded, path: '/manager/queue'),
      const _NavAction(label: 'Shelves', icon: Icons.inventory_2_rounded, path: '/inventory'),
      const _NavAction(label: 'System', icon: Icons.settings_rounded, path: '/profile'),
    ] : [
      const _NavAction(label: 'Home', icon: Icons.home_filled, path: '/dashboard'),
      const _NavAction(label: 'Pending', icon: Icons.assignment_returned_rounded, path: '/requests'),
      const _NavAction(label: 'Inventory', icon: Icons.inventory_2_rounded, path: '/inventory'),
      const _NavAction(label: 'Settings', icon: Icons.settings_rounded, path: '/profile'),
    ];

    // Split for the center Scanner FAB (Functional Parity)
    final leftActions = actions.sublist(0, 2);
    final rightActions = actions.sublist(2, 4);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final now = DateTime.now();
        if (_lastBackPressed == null || now.difference(_lastBackPressed!) > _exitConfirmationDuration) {
          _lastBackPressed = now;
          AppToast.showInfo(context, 'Press back again to exit LIGTAS');
        } else {
          try {
            await _taskChannel.invokeMethod('minimize');
          } catch (e) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFFF5F5F7), 
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _handleActivity();
            return false;
          },
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _handleActivity(),
            onPointerMove: (_) => _handleActivity(),
            child: Column(
              children: [
                const OfflineIndicator(),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: widget.child),
            
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic, 
                        left: 20, 
                        right: 20,
                        bottom: showDock ? (padding.bottom > 0 ? padding.bottom : 8.0) : -120,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: showDock ? 1.0 : 0.0,
                          child: _buildAdaptiveTacticalDock(leftActions, rightActions),
                        ),
                      ),

                      if (isCommsDrawerOpen)
                        GestureDetector(
                          onTap: () => ref.read(commsDrawerStateProvider.notifier).close(),
                          child: Container(color: Colors.black.withOpacity(0.3)).animate().fadeIn(),
                        ),

                      if (!isManager) ...[
                        if (!isKeyboardVisible && !isDockSuppressed)
                          const CommsCapsule(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🏗️ THE ADAPTIVE DOCK
  /// A unified glass-morphic pill that maps polymorphic items and anchors the scanner.
  Widget _buildAdaptiveTacticalDock(List<_NavAction> left, List<_NavAction> right) {
    final sentinel = Theme.of(context).sentinel;
    
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: sentinel.tactile.recessed,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...left.map((action) => _buildTacticalItem(action)),
              _buildScannerDockAction(),
              ...right.map((action) => _buildTacticalItem(action)),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎯 THE TACTICAL ITEM
  /// Route-aware, role-blind, and premium.
  Widget _buildTacticalItem(_NavAction action) {
    // 🛡️ TACTICAL SNIPER: Match selection via route-prefix to ensure sub-pages don't kill the highlight
    final isSelected = widget.location == action.path || 
                      (action.path != '/' && widget.location.startsWith(action.path));
    final sentinel = Theme.of(context).sentinel;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (widget.location != action.path) {
            context.go(action.path);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(
                  action.icon,
                  color: isSelected ? sentinel.navy : sentinel.onSurfaceVariant,
                  size: 24,
                ),
                if (isSelected)
                  Positioned(
                    bottom: -16, // Proximity-locked dot
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: sentinel.navy,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: sentinel.navy.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
                  ),
              ],
            ),
            const Gap(4),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lexend(
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? sentinel.navy : sentinel.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerDockAction() {
    return GestureDetector(
      onTap: _openScanner,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0A0E14), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.1)),
    );
  }
}
