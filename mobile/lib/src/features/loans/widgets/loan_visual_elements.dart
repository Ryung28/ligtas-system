import 'dart:math' as math;
import 'package:flutter/material.dart';

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 80.0;
  @override
  double get maxExtent => 80.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(height: maxExtent, child: child);
  }

  @override
  bool shouldRebuild(StickyTabBarDelegate oldDelegate) => false;
}

class LigtasWavePainter extends CustomPainter {
  final Color color;
  LigtasWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    
    // Smooth wave path
    for (var i = 0; i <= size.width.toInt(); i++) {
       final x = i.toDouble();
       final y = size.height * 0.7 + 
                math.sin(x * 0.01) * 15 + 
                math.cos(x * 0.015) * 10;
       path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
    
    // Second subtle layer
    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);
    for (var i = 0; i <= size.width.toInt(); i++) {
       final x = i.toDouble();
       final y = size.height * 0.8 + 
                math.cos(x * 0.012) * 20 + 
                math.sin(x * 0.008) * 12;
       path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    
    final paint2 = Paint()
      ..color = color.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
