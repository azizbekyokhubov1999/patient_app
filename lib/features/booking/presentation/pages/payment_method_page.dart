import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/booking_route_args.dart';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({
    required this.args,
    super.key,
  });

  final PaymentMethodArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.primaryText),
        ),
        title: const Text('Payment Method', style: AppTextStyles.appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Patient: ${args.patientInfo.name}\nPackage: ${args.selectedPackage.name}\nDate: ${args.selectedDate.toIso8601String().split('T').first}\nTime: ${args.selectedTime}',
          style: const TextStyle(color: AppColors.primaryText),
        ),
      ),
    );
  }
}
