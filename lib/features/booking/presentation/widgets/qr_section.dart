import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';

/// QR code block for the e-receipt ticket header.
class QrSection extends StatelessWidget {
  const QrSection({
    required this.appointmentId,
    this.qrData,
    super.key,
  });

  /// Display label (may be shortened, e.g. `#AB12CD34`).
  final String appointmentId;

  /// Full Firestore document ID encoded in the QR code.
  final String? qrData;

  @override
  Widget build(BuildContext context) {
    final encodedData = qrData ?? appointmentId.replaceAll('#', '');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: QrImageView(
          data: encodedData,
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
