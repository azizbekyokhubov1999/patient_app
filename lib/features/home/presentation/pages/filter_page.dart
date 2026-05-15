import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/filter_result.dart';
import '../manager/filter_cubit.dart';
import '../manager/filter_state.dart';
import '../models/filter_args.dart';
import '../widgets/filter_chips.dart';
import '../widgets/range_slider_section.dart';
import '../widgets/rating_radio_list.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({
    this.args,
    super.key,
  });

  final FilterArgs? args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FilterCubit(initialFilter: args?.initialFilter),
      child: const _FilterView(),
    );
  }
}

class _FilterView extends StatelessWidget {
  const _FilterView();

  static const List<String> _distanceLabels = [
    '3',
    '6',
    '9',
    '12',
    '15',
    '18',
    '21',
    '24',
    '27',
    '30',
  ];

  static const List<String> _feeLabels = [
    r'$10',
    r'$15',
    r'$20',
    r'$25',
    r'$30',
    r'$35',
    r'$40',
    r'$45',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            style: IconButton.styleFrom(
              shape: const CircleBorder(),
              side: const BorderSide(color: AppColors.stroke),
            ),
            onPressed: () => context.pop(),
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.primaryText, size: 20),
          ),
        ),
        title: const Text('Filter', style: AppTextStyles.appBarTitle),
      ),
      body: BlocBuilder<FilterCubit, FilterState>(
        builder: (context, state) {
          final cubit = context.read<FilterCubit>();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Specialist',
                        style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      FilterChips(
                        options: FilterCubit.specialistOptions,
                        selected: state.selectedSpecialist,
                        onSelected: cubit.updateSpecialist,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Consultation Type',
                        style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      FilterChips(
                        options: FilterCubit.consultationTypeOptions,
                        selected: state.selectedConsultationType,
                        onSelected: cubit.updateConsultationType,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Reviews',
                        style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      RatingRadioList(
                        options: FilterCubit.ratingOptions,
                        selected: state.selectedRating,
                        onSelected: cubit.updateRating,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      RangeSliderSection(
                        title: 'Distance (Miles)',
                        values: state.distanceRange,
                        min: 3,
                        max: 30,
                        divisions: 9,
                        scaleLabels: _distanceLabels,
                        onChanged: cubit.updateDistance,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      RangeSliderSection(
                        title: 'Consultation Fee',
                        values: state.feeRange,
                        min: 10,
                        max: 45,
                        divisions: 7,
                        scaleLabels: _feeLabels,
                        onChanged: cubit.updateFee,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextButton(
                          onPressed: cubit.resetFilters,
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.neutral100,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            'Reset Filter',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              final result = cubit.buildResult();
                              context.pop<FilterResult>(result);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text('Apply', style: AppTextStyles.buttonLabel),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
