import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Blue scalloped success badge with checkmark (Figma top-up success).
class TopUpSuccessBadge extends StatelessWidget {
  const TopUpSuccessBadge({this.size = 120, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ScallopedBadgePainter(),
        child: Center(
          child: Icon(
            Icons.check_rounded,
            size: size * 0.42,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _ScallopedBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    const lobes = 12;

    final path = Path();
    for (var i = 0; i < lobes * 2; i++) {
      final angle = (math.pi * i) / lobes - math.pi / 2;
      final radius = i.isEven ? outerRadius : outerRadius * 0.86;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
