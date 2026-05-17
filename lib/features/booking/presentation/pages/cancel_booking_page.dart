import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../manager/cancel_booking_cubit.dart';
import '../manager/cancel_booking_state.dart';
import '../manager/cancelled_appointments_cubit.dart';
import '../manager/upcoming_appointments_cubit.dart';

/// Predefined cancellation reasons (Figma).
const List<String> kCancellationReasons = [
  'Prefer a different specialist',
  'Booked by mistake',
  'Service no longer needed',
  'Emergency came up',
  'Found another appointment',
  CancelBookingState.otherReasonLabel,
];

class CancelBookingPage extends StatefulWidget {
  const CancelBookingPage({required this.appointmentId, super.key});

  final String appointmentId;

  @override
  State<CancelBookingPage> createState() => _CancelBookingPageState();
}

class _CancelBookingPageState extends State<CancelBookingPage> {
  final TextEditingController _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CancelBookingCubit, CancelBookingState>(
      listenWhen: (previous, current) =>
          previous.isSubmitting != current.isSubmitting ||
          previous.errorMessage != current.errorMessage ||
          previous.isSuccess != current.isSuccess,
      listener: (context, state) {
        if (state.isSubmitting) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
          return;
        }

        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }

        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment successfully cancelled'),
              backgroundColor: AppColors.success,
            ),
          );
          try {
            context
                .read<UpcomingAppointmentsCubit>()
                .cancelAppointment(widget.appointmentId);
          } catch (_) {}
          try {
            context.read<CancelledAppointmentsCubit>().fetchCancelledAppointments();
          } catch (_) {}
          context.go(AppPaths.appointments, extra: 2);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: const CustomAppBar(
          title: 'Cancel Booking',
          backgroundColor: AppColors.white,
        ),
        body: BlocBuilder<CancelBookingCubit, CancelBookingState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Please select the reason for cancellations:',
                          style: AppTextStyles.doctorMeta.copyWith(
                            fontSize: 15,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...kCancellationReasons.map(
                          (reason) => _ReasonTile(
                            label: reason,
                            groupValue: state.selectedReason,
                            onSelected: () => context
                                .read<CancelBookingCubit>()
                                .selectReason(reason),
                          ),
                        ),
                        if (state.selectedReason ==
                            CancelBookingState.otherReasonLabel) ...[
                          const SizedBox(height: 20),
                          Text(
                            CancelBookingState.otherReasonLabel,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _otherController,
                            maxLines: 5,
                            onChanged: context
                                .read<CancelBookingCubit>()
                                .updateOtherReasonText,
                            decoration: InputDecoration(
                              hintText: 'Enter your Reason',
                              hintStyle: AppTextStyles.doctorMeta.copyWith(
                                fontSize: 14,
                                color: AppColors.secondaryText
                                    .withValues(alpha: 0.7),
                              ),
                              filled: true,
                              fillColor: AppColors.neutral100,
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
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: state.canSubmit && !state.isSubmitting
                            ? () => context
                                .read<CancelBookingCubit>()
                                .submitCancellation(widget.appointmentId)
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.45),
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Cancel Booking',
                          style: AppTextStyles.buttonLabel,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.label,
    required this.groupValue,
    required this.onSelected,
  });

  final String label;
  final String groupValue;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _RadioIndicator(selected: groupValue == label),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.stroke,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
