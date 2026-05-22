import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../manager/upcoming_appointments_cubit.dart';
import '../models/consultation_ended_args.dart';
import '../widgets/dashed_divider.dart';
import '../widgets/verified_doctor_avatar.dart';

/// Shown when an in-app or telehealth consultation session has finished.
class ConsultationEndedPage extends StatefulWidget {
  const ConsultationEndedPage({required this.args, super.key});

  final ConsultationEndedArgs args;

  @override
  State<ConsultationEndedPage> createState() => _ConsultationEndedPageState();
}

class _ConsultationEndedPageState extends State<ConsultationEndedPage> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _finishAndGoHome() {
    try {
      context
          .read<UpcomingAppointmentsCubit>()
          .clearPendingConsultationEnd();
    } catch (_) {}
    context.go(AppPaths.appointments, extra: 1);
  }

  void _onSubmitFeedback() {
    if (_submitted) return;
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your feedback!')),
    );
    _finishAndGoHome();
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.args.doctor;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: '',
        backgroundColor: AppColors.white,
        onBack: _finishAndGoHome,
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
                  const SizedBox(height: 32),
                  Text(
                    'How was your consultation?',
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        onPressed: () => setState(() => _rating = starIndex),
                        icon: Icon(
                          starIndex <= _rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 40,
                          color: AppColors.yellow,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Leave a comment (optional)',
                      hintStyle: AppTextStyles.doctorMeta.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.stroke),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.stroke),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
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
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submitted ? null : _onSubmitFeedback,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Submit Feedback',
                        style: AppTextStyles.buttonLabel,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _finishAndGoHome,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.neutral100,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: AppTextStyles.buttonLabel,
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
