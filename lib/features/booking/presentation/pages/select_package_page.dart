import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/package_type.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../models/booking_route_args.dart';
import '../widgets/package_card.dart';

class SelectPackagePage extends StatelessWidget {
  const SelectPackagePage({
    required this.args,
    super.key,
  });

  final SelectPackageArgs args;

  @override
  Widget build(BuildContext context) {
    final doctorId = args.doctorId ?? args.doctor?.name.toLowerCase().replaceAll(' ', '_') ?? 'doctor';

    return BlocProvider(
      create: (_) => BookingBloc(
        repository: BookingRepositoryImpl(BookingRemoteDataSourceImpl()),
        doctorId: doctorId,
        initialDate: args.selectedDate,
        initialSelectedTime: args.selectedTime,
        initialSelectedPackage: args.selectedPackage,
      ),
      child: _SelectPackageView(args: args),
    );
  }
}

class _SelectPackageView extends StatelessWidget {
  const _SelectPackageView({required this.args});

  final SelectPackageArgs args;

  @override
  Widget build(BuildContext context) {
    const options = [
      PackageType.messaging,
      PackageType.voiceCall,
      PackageType.videoCall,
      PackageType.inPerson,
    ];

    return BlocBuilder<BookingBloc, BookingState>(
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
                borderRadius: BorderRadius.circular(24),
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
            title: const Text('Select Package', style: AppTextStyles.appBarTitle),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 120),
            children: [
              const Text('Select Package', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSpacing.lg),
              ...options.map(
                (package) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: PackageCard(
                    package: package,
                    selected: state.selectedPackage == package,
                    onTap: () => context.read<BookingBloc>().add(SelectPackageEvent(package)),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: state.selectedPackage == null
                    ? null
                    : () {
                        context.push(
                          AppPaths.patientDetails,
                          extra: PatientDetailsArgs(
                            selectedDate: args.selectedDate,
                            selectedTime: args.selectedTime,
                            selectedPackage: state.selectedPackage!,
                            doctor: args.doctor,
                            doctorId: args.doctorId,
                            hospital: args.hospital,
                          ),
                        );
                      },
                child: const Text(
                  'Continue',
                  style: AppTextStyles.buttonLabel,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
