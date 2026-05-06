import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/doctor_review.dart';
import '../manager/leave_review_doctor_cubit.dart';
import '../manager/leave_review_doctor_state.dart';

class LeaveReviewDoctorPage extends StatelessWidget {
  const LeaveReviewDoctorPage({required this.doctor, super.key});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeaveReviewDoctorCubit(doctor),
      child: _LeaveReviewDoctorView(doctor: doctor),
    );
  }
}

class _LeaveReviewDoctorView extends StatelessWidget {
  const _LeaveReviewDoctorView({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final firstName = doctor.name.split(' ').where((e) => e.isNotEmpty).first;

    return BlocBuilder<LeaveReviewDoctorCubit, LeaveReviewDoctorState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
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
                    size: 20,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),
            centerTitle: true,
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
                _DoctorProfileCard(doctor: doctor),
                const SizedBox(height: 26),
                Text(
                  'How was your experience with $firstName?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                    fontSize: 34,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 14),
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          final value = index + 1;
                          final selected = value <= state.rating;
                          return InkWell(
                            onTap: () => context
                                .read<LeaveReviewDoctorCubit>()
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
                const SizedBox(height: 26),
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
                      .read<LeaveReviewDoctorCubit>()
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
                const SizedBox(height: 18),
                InkWell(
                  onTap: () => debugPrint('add photo tapped'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.camera,
                        color: AppColors.primaryText,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'add photo',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
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
                onPressed: () {
                  final review = context
                      .read<LeaveReviewDoctorCubit>()
                      .submitReview();
                  context.pop<DoctorReview>(review);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DoctorProfileCard extends StatelessWidget {
  const _DoctorProfileCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.stroke,
                backgroundImage: NetworkImage(doctor.imageUrl),
              ),
              const Positioned(
                right: -2,
                bottom: -2,
                child: Icon(
                  LucideIcons.badgeCheck,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                    fontSize: 34,
                  ),
                ),
                Text(
                  doctor.specialty,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.star,
                      color: Colors.amber,
                      fill: 1,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
