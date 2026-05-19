import 'package:flutter/material.dart';

/// Ticket-shaped clip with mirrored side notches at ~70% height.
class CouponClipper extends CustomClipper<Path> {
  const CouponClipper({
    this.cornerRadius = 16,
    this.notchRadius = 10,
    this.notchFactor = 0.7,
  });

  final double cornerRadius;
  final double notchRadius;
  final double notchFactor;

  @override
  Path getClip(Size size) {
    final notchY = size.height * notchFactor;
    final r = cornerRadius;
    final n = notchRadius;
    final w = size.width;
    final h = size.height;

    final path = Path();

    path.moveTo(r, 0);
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);

    path.lineTo(w, notchY - n);
    path.arcToPoint(
      Offset(w, notchY + n),
      radius: Radius.circular(n),
      clockwise: false,
    );

    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);

    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);

    path.lineTo(0, notchY + n);
    path.arcToPoint(
      Offset(0, notchY - n),
      radius: Radius.circular(n),
      clockwise: false,
    );

    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
