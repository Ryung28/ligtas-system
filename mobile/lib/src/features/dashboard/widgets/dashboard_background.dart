import 'package:flutter/material.dart';

/// Sentinel Canvas Background
/// Replaced with pure white background as per user request.
class DashboardBackground extends StatelessWidget {
  const DashboardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }
}
