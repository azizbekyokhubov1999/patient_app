import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/hospital.dart';
import '../cubit/leave_review_hospital_cubit.dart';
import '../cubit/leave_review_hospital_state.dart';

class LeaveReviewHospitalPage extends StatelessWidget {
  const LeaveReviewHospitalPage({required this.hospital, super.key});

  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeaveReviewHospitalCubit(hospital),
      child: _LeaveReviewHospitalView(hospital: hospital),
    );
  }
}

class _LeaveReviewHospitalView extends StatelessWidget {
  const _LeaveReviewHospitalView({required this.hospital});

  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaveReviewHospitalCubit, LeaveReviewHospitalState>(
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
                _HospitalProfileCard(hospital: hospital),
                const SizedBox(height: 24),
                Text(
                  'How was your experience?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                    fontSize: 34,
                  ),
                ),
                const SizedBox(height: 12),
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
                  'Specialist',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _pickSpecialist(context, hospital.specialists),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.selectedSpecialist?.name ??
                                'Select specialist',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.primaryText),
                          ),
                        ),
                        const Icon(
                          LucideIcons.chevronDown,
                          color: AppColors.primaryText,
                          size: 18,
                        ),
                      ],
                    ),
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
                const SizedBox(height: 16),
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
                  final updated = context
                      .read<LeaveReviewHospitalCubit>()
                      .submitReview();
                  context.pop<Hospital>(updated);
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

  Future<void> _pickSpecialist(BuildContext context, List<Doctor> list) async {
    if (list.isEmpty) return;
    final selected = await showModalBottomSheet<Doctor>(
      context: context,
      backgroundColor: AppColors.white,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: list.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: AppColors.stroke),
            itemBuilder: (context, index) {
              final doctor = list[index];
              return ListTile(
                title: Text(doctor.name),
                subtitle: Text(doctor.specialty),
                onTap: () => Navigator.of(context).pop(doctor),
              );
            },
          ),
        );
      },
    );
    if (selected != null && context.mounted) {
      context.read<LeaveReviewHospitalCubit>().setSpecialist(selected);
    }
  }
}

class _HospitalProfileCard extends StatelessWidget {
  const _HospitalProfileCard({required this.hospital});

  final Hospital hospital;

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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              hospital.imageUrl,
              width: 76,
              height: 76,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 76,
                height: 76,
                color: AppColors.stroke,
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.imageOff,
                  size: 20,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                    fontSize: 34,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.mapPin,
                      size: 16,
                      color: AppColors.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hospital.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.secondaryText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.clock3,
                      size: 16,
                      color: AppColors.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${hospital.eta} • ${hospital.distance}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.secondaryText,
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
