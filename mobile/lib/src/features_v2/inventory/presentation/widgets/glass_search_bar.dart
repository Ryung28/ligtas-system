import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';

class GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const GlassSearchBar({super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: sentinel.containerLow,
        borderRadius: BorderRadius.circular(16),
        // No border or shadow in default state per design system
      ),
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: sentinel.onSurfaceVariant.withOpacity(0.5), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: sentinel.navy,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search inventory...',
                hintStyle: TextStyle(
                  color: sentinel.onSurfaceVariant.withOpacity(0.4), 
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: sentinel.containerLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: sentinel.raisedShadow,
            ),
            child: Icon(Icons.tune_rounded, size: 20, color: sentinel.navy),
          ),
        ],
      ),
    );
  }
}
