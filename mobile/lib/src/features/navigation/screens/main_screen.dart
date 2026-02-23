import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../scanner/widgets/scanner_view.dart';
import '../../scanner/models/qr_payload.dart';
import '../../scanner/widgets/scan_result_sheet.dart';
import '../../../core/design_system/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../../../core/design_system/widgets/offline_indicator.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;
  final String location;

  const MainScreen({super.key, required this.child, required this.location});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  bool _isDockVisible = true;
  Timer? _hideTimer;
  
  @override
  void initState() {
    super.initState();
    _syncIndexFromRoute();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
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

  void _handleActivity() {
    // Senior Dev Logic: If navigation is suppressed (e.g. detailed view open), 
    // we ignore activity triggers to keep the UI focused.
    final isSuppressed = ref.read(isDockSuppressedProvider);
    if (isSuppressed) return;

    if (!_isDockVisible) {
      setState(() => _isDockVisible = true);
    }
    _startHideTimer();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/loans');
        break;
      case 2:
        context.go('/inventory');
        break;
      case 3:
        context.go('/profile');
        break;
    }
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
    _syncIndexFromRoute();
    _handleActivity(); // Reset timer on route change
  }


  void _syncIndexFromRoute() {
    final location = widget.location;
    int index = 0;
    if (location.startsWith('/dashboard')) {
      index = 0;
    } else if (location.startsWith('/loans') || location.startsWith('/requests')) {
      index = 1;
    } else if (location.startsWith('/inventory')) {
      index = 2;
    } else if (location.startsWith('/profile')) {
      index = 3;
    }

    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final bottomOffset = padding.bottom > 0 ? padding.bottom : 24.0;
    
    // Watch suppression state
    final isDockSuppressed = ref.watch(isDockSuppressedProvider);
    
    // Senior Dev: Force hide dock if keyboard is visible OR if suppressed by a detail view
    final isKeyboardVisible = viewInsets.bottom > 0;
    
    // Auto-restore visibility when suppression is lifted
    ref.listen(isDockSuppressedProvider, (previous, next) {
      if (previous == true && next == false) {
        // Force show dock when suppression ends - this fixes the issue where
        // dock doesn't reappear after scanning on home tab
        if (!_isDockVisible) {
          setState(() => _isDockVisible = true);
        }
        _startHideTimer();
      }
    });

    final showDock = _isDockVisible && !isKeyboardVisible && !isDockSuppressed;
    
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF5F5F7), 
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Senior Dev: Scrolling is valid activity. Pop the dock.
          _handleActivity();
          return false; // Don't consume
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
                    // 1. Content Area
                    Positioned.fill(child: widget.child),
          
                    // 2. Floating Glass Dock (Smart Stealth)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400), // Slightly smoother transition
                      curve: Curves.easeOutCubic, 
                      left: 20,
                      right: 20,
                      bottom: showDock ? bottomOffset : -120,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: showDock ? 1.0 : 0.0,
                        child: _buildFloatingDock(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingDock() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.6),
            Colors.white.withOpacity(0.3),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDockItem(index: 0, icon: Icons.home_rounded, label: 'Home'),
                _buildDockItem(index: 1, icon: Icons.assignment_returned_rounded, label: 'Borrow'),
                
                // Central Scanner Button (Keep this as it's a core feature of LIGTAS)
                _buildScannerDockAction(),
                
                _buildDockItem(index: 2, icon: Icons.inventory_2_rounded, label: 'Inventory'),
                _buildDockItem(index: 3, icon: Icons.settings_rounded, label: 'Setting'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem({required int index, required IconData icon, required String label}) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.neutralGray500,
              size: 24,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
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
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
