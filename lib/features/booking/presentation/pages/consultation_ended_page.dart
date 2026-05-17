import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../models/consultation_ended_args.dart';
import '../widgets/dashed_divider.dart';
import '../widgets/verified_doctor_avatar.dart';

/// Shown when an in-app or telehealth consultation session has finished.
class ConsultationEndedPage extends StatelessWidget {
  const ConsultationEndedPage({required this.args, super.key});

  final ConsultationEndedArgs args;

  void _goHome(BuildContext context) => context.go(AppPaths.home);

  @override
  Widget build(BuildContext context) {
    final doctor = args.doctor;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: '',
        backgroundColor: AppColors.white,
        onBack: () => _goHome(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      size: 40,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'The Consultation Session has ended',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontSize: 24,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Thank you for consulting with us today.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      height: 1.45,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const DashedDivider(
                    showNotches: false,
                    dashColor: AppColors.stroke,
                    backgroundColor: AppColors.white,
                  ),
                  const SizedBox(height: 32),
                  VerifiedDoctorAvatar(imageUrl: doctor.imageUrl),
                  const SizedBox(height: 20),
                  Text(
                    doctor.name,
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    doctor.specialty,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: AppColors.yellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        doctor.rating.toStringAsFixed(1),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _goHome(context),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.neutral100,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Back to Home',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => context.push(
                        AppPaths.leaveReviewDoctor,
                        extra: doctor,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Add Review',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
