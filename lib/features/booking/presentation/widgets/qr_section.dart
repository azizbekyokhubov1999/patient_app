import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';

/// QR code block for the e-receipt ticket header.
class QrSection extends StatelessWidget {
  const QrSection({
    required this.appointmentId,
    super.key,
  });

  final String appointmentId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: QrImageView(
          data: appointmentId,
          version: QrVersions.auto,
          size: 200,
          backgroundColor: AppColors.white,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: AppColors.primaryText,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}
