import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/appointment_detail_args.dart';

/// Placeholder detail screen; extend when appointment-detail UX is finalized.
class AppointmentDetailPage extends StatelessWidget {
  const AppointmentDetailPage({required this.args, super.key});

  final AppointmentDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Appointment',
          style: theme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Appointment ID:\n${args.appointmentId}',
            textAlign: TextAlign.center,
            style: theme.bodyLarge?.copyWith(color: AppColors.secondaryText),
          ),
        ),
      ),
    );
  }
}
