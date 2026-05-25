import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Circular doctor photo with a verified badge at the bottom-right (Figma).
class VerifiedDoctorAvatar extends StatelessWidget {
  const VerifiedDoctorAvatar({
    required this.imageUrl,
    this.radius = 60,
    super.key,
  });

  final String imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final badgeSize = radius * 0.42;

    return SizedBox(
      width: radius * 2 + badgeSize * 0.35,
      height: radius * 2 + badgeSize * 0.35,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.neutral200,
            child: ClipOval(child: _AvatarImage(imageUrl: imageUrl, size: radius * 2)),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _VerifiedBadge(size: badgeSize),
          ),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.imageUrl, required this.size});

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Icon(
      Icons.person_rounded,
      size: size * 0.5,
      color: AppColors.secondaryText.withValues(alpha: 0.45),
    );

    if (imageUrl.isEmpty) {
      return SizedBox(width: size, height: size, child: Center(child: placeholder));
    }

    return Image.network(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Center(child: placeholder),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: size * 0.35,
            height: size * 0.35,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
        );
      },
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({required this.size});

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
            size: size * 0.55,
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
      final r = i.isEven ? outerRadius : outerRadius * 0.86;
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
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
