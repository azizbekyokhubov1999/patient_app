import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/coupon_model.dart';
import 'coupon_clipper.dart';

class CouponCard extends StatelessWidget {
  const CouponCard({required this.coupon, super.key});

  final CouponModel coupon;

  static const double _notchFactor = 0.7;

  @override
  Widget build(BuildContext context) {
    const clipper = CouponClipper(notchFactor: _notchFactor);

    return Material(
      color: Colors.transparent,
      elevation: 1.5,
      shadowColor: Colors.black26,
      child: PhysicalShape(
        clipper: clipper,
        color: AppColors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          coupon.code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      _StatusBadge(coupon: coupon),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    coupon.unlockCondition,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _DiscountStarBadge(),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          coupon.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DashedDividerPainter(),
              ),
            ),
            ColoredBox(
              color: AppColors.neutral100,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: TextButton(
                    onPressed: () => _copyCode(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    child: const Text(
                      'COPY CODE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: coupon.code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard!')),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.coupon});

  final CouponModel coupon;

  @override
  Widget build(BuildContext context) {
    if (coupon.isLocked) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.stroke),
        ),
        child: const Icon(
          Icons.lock_outline,
          size: 16,
          color: AppColors.secondaryText,
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 16,
        color: AppColors.white,
      ),
    );
  }
}

class _DiscountStarBadge extends StatelessWidget {
  const _DiscountStarBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: CustomPaint(
        painter: _StarburstPainter(),
        child: const Center(
          child: Text(
            '%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _StarburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.55;
    const points = 12;
    final path = Path();

    for (var i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final radius = isOuter ? outerRadius : innerRadius;
      final angle = (i * math.pi / points) - math.pi / 2;
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
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = AppColors.stroke
      ..strokeWidth = 1;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
