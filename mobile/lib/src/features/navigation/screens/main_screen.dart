import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../scanner/widgets/scanner_view.dart';
import '../../scanner/models/qr_payload.dart';
import '../../scanner/widgets/scan_result_sheet.dart';
import '../../../core/design_system/app_theme.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  final String location;

  const MainScreen({super.key, required this.child, required this.location});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

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
        builder:
            (context) => ScannerView(
              onQrCodeDetected: (qrCode) {
                Navigator.of(context).pop();
                _handleScannedCode(qrCode);
              },
              overlayText: 'Scan CDRRMO equipment QR code to see details',
            ),
      ),
    );
  }

  void _handleScannedCode(String qrCode) {
    final payload = LigtasQrPayload.tryParse(qrCode);
    
    if (payload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR Code. Please scan a LIGTAS equipment label.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show the "Senior" Review Modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScanResultSheet(payload: payload),
    );
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncIndexFromRoute();
  }

  @override
  void initState() {
    super.initState();
    _syncIndexFromRoute();
  }

  void _syncIndexFromRoute() {
    final location = widget.location;
    int index = 0;
    if (location.startsWith('/dashboard')) {
      index = 0;
    } else if (location.startsWith('/loans')) {
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
    return Scaffold(
      extendBody: true,
      body: widget.child,
      floatingActionButton: _buildProminentQRButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildProminentQRButton() {
    return Container(
      height: 56,
      width: 56,
      margin: const EdgeInsets.only(top: 4), // Lifted higher
      child: FloatingActionButton(
        onPressed: _openScanner,
        elevation: 6,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      height: 58, // Slimmer height
      padding: EdgeInsets.zero,
      notchMargin: 4,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildNavItem(
              icon: Icons.grid_view_rounded,
              label: 'Home',
              index: 0,
              isSelected: _selectedIndex == 0,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              icon: Icons.list_alt_rounded,
              label: 'My Items',
              index: 1,
              isSelected: _selectedIndex == 1,
            ),
          ),
          // Gap for the FAB
          const SizedBox(width: 70),
          Expanded(
            child: _buildNavItem(
              icon: Icons.search_rounded,
              label: 'Inventory',
              index: 2,
              isSelected: _selectedIndex == 2,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              index: 3,
              isSelected: _selectedIndex == 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    // Special handling for center tab to fit under FAB
    bool isCenter = index == 2;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isCenter)
            const SizedBox(height: 20)
          else
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.neutralGray500,
                size: 20,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.neutralGray600,
            ),
          ),
        ],
      ),
    );
  }


}
