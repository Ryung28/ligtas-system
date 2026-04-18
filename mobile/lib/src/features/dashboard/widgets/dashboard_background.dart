import 'package:flutter/material.dart';
import '../../../core/design_system/app_theme.dart';

/// Sentinel Canvas Background
/// Updated to Soft Grey-White (#F2F4F8) as per Central Intelligence design.
class DashboardBackground extends StatelessWidget {
  const DashboardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    return Container(
      color: sentinel.containerLow,
    );
  }
}
