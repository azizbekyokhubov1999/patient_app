import 'package:flutter/material.dart';

/// Horizontal dashed line with optional ticket-style side notches.
class DashedDivider extends StatelessWidget {
  const DashedDivider({
    this.notchRadius = 12,
    this.dashColor = const Color(0xFFD1D5DB),
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.showNotches = true,
    super.key,
  });

  final double notchRadius;
  final Color dashColor;
  final Color backgroundColor;
  final bool showNotches;

  @override
  Widget build(BuildContext context) {
    final height = showNotches ? notchRadius * 2 : 1.0;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedDividerPainter(
          dashColor: dashColor,
          backgroundColor: backgroundColor,
          notchRadius: notchRadius,
          showNotches: showNotches,
        ),
      ),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  _DashedDividerPainter({
    required this.dashColor,
    required this.backgroundColor,
    required this.notchRadius,
    required this.showNotches,
  });

  final Color dashColor;
  final Color backgroundColor;
  final double notchRadius;
  final bool showNotches;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    if (showNotches) {
      final notchPaint = Paint()..color = backgroundColor;
      canvas.drawCircle(Offset(0, centerY), notchRadius, notchPaint);
      canvas.drawCircle(Offset(size.width, centerY), notchRadius, notchPaint);
    }

    final dashPaint = Paint()
      ..color = dashColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 5.0;
    var startX = showNotches ? notchRadius : 0.0;
    final endX = showNotches ? size.width - notchRadius : size.width;

    while (startX < endX) {
      final x2 = (startX + dashWidth).clamp(0.0, endX).toDouble();
      if (x2 > startX) {
        canvas.drawLine(Offset(startX, centerY), Offset(x2, centerY), dashPaint);
      }
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter oldDelegate) {
    return oldDelegate.dashColor != dashColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.notchRadius != notchRadius ||
        oldDelegate.showNotches != showNotches;
  }
}
