import 'package:flutter/material.dart';

class LoginBackgroundPattern extends StatelessWidget {
  const LoginBackgroundPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: DotPatternPainter(),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    const double spacing = 40.0;
    const double radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Offset every other row for a honeycomb/pattern effect if desired, 
        // but standard grid is cleaner for professional looks.
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
