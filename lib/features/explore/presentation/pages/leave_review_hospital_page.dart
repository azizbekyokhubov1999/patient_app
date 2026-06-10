import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/hospital.dart';
import '../cubit/leave_review_hospital_cubit.dart';
import '../cubit/leave_review_hospital_state.dart';

class LeaveReviewHospitalPage extends StatelessWidget {
  const LeaveReviewHospitalPage({required this.hospital, super.key});

  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeaveReviewHospitalCubit(
        hospital: hospital,
        homeRepository: AppDependencies.instance.homeRepository,
        profileRepository: AppDependencies.instance.profileRepository,
      ),
      child: const _LeaveReviewHospitalView(),
    );
  }
}

class _LeaveReviewHospitalView extends StatelessWidget {
  const _LeaveReviewHospitalView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeaveReviewHospitalCubit, LeaveReviewHospitalState>(
      listenWhen: (previous, current) =>
          previous.submitSuccess != current.submitSuccess ||
          previous.submitError != current.submitError,
      listener: (context, state) {
        if (state.submitSuccess) {
          context.read<LeaveReviewHospitalCubit>().clearSubmitStatus();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully')),
          );
          context.pop();
          return;
        }

        if (state.submitError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.submitError!)),
          );
          context.read<LeaveReviewHospitalCubit>().clearSubmitStatus();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    color: AppColors.primaryText,
                    size: 20,
                  ),
                ),
              ),
            ),
            title: const Text(
              'Leave Review',
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your overall rating',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          final value = index + 1;
                          final selected = value <= state.rating;
                          return InkWell(
                            onTap: () => context
                                .read<LeaveReviewHospitalCubit>()
                                .setRating(value),
                            child: Icon(
                              LucideIcons.star,
                              size: 42,
                              color: selected ? Colors.amber : AppColors.stroke,
                              fill: selected ? 1 : 0,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Add detailed review',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  minLines: 5,
                  maxLines: 8,
                  onChanged: context
                      .read<LeaveReviewHospitalCubit>()
                      .setReviewText,
                  decoration: InputDecoration(
                    hintText: 'Enter here',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () =>
                        context.read<LeaveReviewHospitalCubit>().submitReview(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
