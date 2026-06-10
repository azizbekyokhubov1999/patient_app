import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../manager/get_direction_args.dart';

/// Arrival confirmation — scan E-Receipt QR at the hospital.
class YouHaveArrivedPage extends StatelessWidget {
  const YouHaveArrivedPage({this.args, super.key});

  final GetDirectionArgs? args;

  void _openEReceipt(BuildContext context) {
    final receipt = args?.eReceipt;
    if (receipt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-Receipt not available for this visit')),
      );
      return;
    }

    final path = GoRouterState.of(context).uri.path.startsWith('/appointments')
        ? AppPaths.appointmentEReceipt
        : AppPaths.eReceipt;
    context.push(path, extra: receipt);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isFromAppointment = args?.isFromAppointment ?? false;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: '',
        backgroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _ArrivalVerifiedBadge(size: 120),
                    const SizedBox(height: 32),
                    Text(
                      'You Have Arrived!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isFromAppointment
                          ? 'Please scan your E-Receipt QR code at the scanner machine.'
                          : 'Thank you for using our app!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.doctorMeta.copyWith(
                        fontSize: 16,
                        height: 1.45,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isFromAppointment
                      ? () => _openEReceipt(context)
                      : () => context.go(AppPaths.home),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isFromAppointment ? 'Scan QR Code' : 'Back to Home',
                    style: AppTextStyles.buttonLabel,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Blue scalloped verified badge with centered checkmark (Figma).
class _ArrivalVerifiedBadge extends StatelessWidget {
  const _ArrivalVerifiedBadge({required this.size});

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
            size: size * 0.4,
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
