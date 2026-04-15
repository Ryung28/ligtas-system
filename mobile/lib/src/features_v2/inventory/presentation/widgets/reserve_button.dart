import 'package:flutter/material.dart';
import '../../../../core/design_system/app_theme.dart';

class ReserveButton extends StatelessWidget {
  final VoidCallback onTap;

  const ReserveButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            sentinel.onPrimaryFixedVariant, // Deep Navy Sheen
            sentinel.navy, // Deep Navy Base
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              'Request',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
