import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/doctor_review.dart';
import '../../../home/domain/entities/working_hours_entry.dart';
import '../../domain/entities/appointment_model.dart';
import '../manager/cancelled_appointments_cubit.dart';
import '../manager/cancelled_appointments_state.dart';
import '../manager/completed_appointments_cubit.dart';
import '../manager/completed_appointments_state.dart';
import '../manager/upcoming_appointments_cubit.dart';
import '../manager/upcoming_appointments_state.dart';
import '../utils/appointment_flow_navigation.dart';
import '../widgets/cancelled_appointment_card.dart';
import '../widgets/completed_appointment_card.dart';
import '../widgets/upcoming_appointment_card.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({this.initialTabIndex = 0, super.key});

  /// 0 = Upcoming, 1 = Completed, 2 = Cancelled.
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpcomingAppointmentsCubit, UpcomingAppointmentsState>(
      listenWhen: (previous, current) =>
          current is UpcomingAppointmentsLoaded &&
          current.appointmentPendingConsultationEnd != null &&
          (previous is! UpcomingAppointmentsLoaded ||
              previous.appointmentPendingConsultationEnd?.documentId !=
                  current.appointmentPendingConsultationEnd?.documentId),
      listener: (context, state) {
        final loaded = state as UpcomingAppointmentsLoaded;
        final completed = loaded.appointmentPendingConsultationEnd;
        if (completed == null) return;

        context.read<CompletedAppointmentsCubit>().addCompleted(completed);
        navigateConsultationEnded(context, completed);
        context.read<UpcomingAppointmentsCubit>().clearPendingConsultationEnd();
      },
      child: DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex.clamp(0, 2),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: context.canPop()
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => context.pop(),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.stroke),
                        color: AppColors.white,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                )
              : null,
          title: const Text(
            'Appointments',
            style: AppTextStyles.headlineSmall,
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.secondaryText,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UpcomingTab(),
            _CompletedTab(),
            _CancelledTab(),
          ],
        ),
      ),
      ),
    );
  }
}

class _UpcomingTab extends StatefulWidget {
  const _UpcomingTab();

  @override
  State<_UpcomingTab> createState() => _UpcomingTabState();
}

class _UpcomingTabState extends State<_UpcomingTab> {
  @override
  void initState() {
    super.initState();
    context.read<UpcomingAppointmentsCubit>().startTimeRefreshTimer();
  }

  Future<void> _confirmCancel(
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Appointment',
          style: AppTextStyles.titleMedium,
        ),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
          style: AppTextStyles.doctorMeta,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (approved != true || !context.mounted) return;

    final success = await context
        .read<UpcomingAppointmentsCubit>()
        .cancelAppointment(appointment.documentId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled successfully'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpcomingAppointmentsCubit, UpcomingAppointmentsState>(
      builder: (context, state) {
        return switch (state) {
          UpcomingAppointmentsInitial() ||
          UpcomingAppointmentsLoading() =>
            const Center(child: CircularProgressIndicator()),
          UpcomingAppointmentsError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.doctorMeta,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context
                          .read<UpcomingAppointmentsCubit>()
                          .fetchUpcomingAppointments(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          UpcomingAppointmentsLoaded(:final appointments) =>
            appointments.isEmpty
                ? const _PlaceholderTab(
                    message: 'No upcoming appointments yet',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: appointments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return UpcomingAppointmentCard(
                        appointment: appointment,
                        onCancel: () => _confirmCancel(context, appointment),
                        onViewReceipt: () => context.push(
                          AppPaths.eReceipt,
                          extra: eReceiptArgsFromAppointment(appointment)
                              .copyWith(hospitalKioskFlow: false),
                        ),
                        onToggleReminder: (enabled) => context
                            .read<UpcomingAppointmentsCubit>()
                            .toggleReminder(
                              appointment.documentId,
                              enabled,
                            ),
                        onDoctorTap: () => context.push(
                          AppPaths.doctorDetails,
                          extra: _doctorFrom(appointment),
                        ),
                        onJoinSession: appointment.showJoinSession
                            ? () => navigateJoinSession(context, appointment)
                            : null,
                        onGetDirection: appointment.showGetDirection
                            ? () => navigateGetDirection(context, appointment)
                            : null,
                        onScanQr: appointment.showScanQR
                            ? () => navigateScanQr(context, appointment)
                            : null,
                      );
                    },
                  ),
        };
      },
    );
  }
}

class _CompletedTab extends StatelessWidget {
  const _CompletedTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompletedAppointmentsCubit, CompletedAppointmentsState>(
      builder: (context, state) {
        return switch (state) {
          CompletedAppointmentsInitial() ||
          CompletedAppointmentsLoading() =>
            const Center(child: CircularProgressIndicator()),
          CompletedAppointmentsError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.doctorMeta,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context
                          .read<CompletedAppointmentsCubit>()
                          .fetchCompletedAppointments(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          CompletedAppointmentsLoaded(:final appointments) =>
            appointments.isEmpty
                ? const _PlaceholderTab(
                    message: 'No completed appointments yet',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: appointments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return CompletedAppointmentCard(
                        appointment: appointment,
                        onLeaveReview: () => context.push(
                          AppPaths.leaveReview,
                          extra: <String, dynamic>{
                            'appointmentId': appointment.appointmentId,
                            'doctorId': appointment.doctorId ?? '',
                            'doctor': _doctorFrom(appointment),
                            'doctorName': appointment.doctorName,
                            'doctorSpecialty': appointment.doctorSpecialty,
                            'doctorRating': appointment.doctorRating,
                            'doctorImageUrl': appointment.doctorImageUrl,
                          },
                        ),
                        onViewReceipt: () => context.push(
                          AppPaths.eReceipt,
                          extra: eReceiptArgsFromAppointment(appointment)
                              .copyWith(hospitalKioskFlow: false),
                        ),
                        onDoctorTap: () => context.push(
                          AppPaths.doctorDetails,
                          extra: _doctorFrom(appointment),
                        ),
                      );
                    },
                  ),
        };
      },
    );
  }
}

class _CancelledTab extends StatelessWidget {
  const _CancelledTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CancelledAppointmentsCubit, CancelledAppointmentsState>(
      builder: (context, state) {
        return switch (state) {
          CancelledAppointmentsInitial() ||
          CancelledAppointmentsLoading() =>
            const Center(child: CircularProgressIndicator()),
          CancelledAppointmentsError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.doctorMeta,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context
                          .read<CancelledAppointmentsCubit>()
                          .fetchCancelledAppointments(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          CancelledAppointmentsLoaded(:final appointments) =>
            appointments.isEmpty
                ? const _PlaceholderTab(
                    message: 'No cancelled appointments',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: appointments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      final doctor = _doctorFrom(appointment);
                      return CancelledAppointmentCard(
                        appointment: appointment,
                        onReBook: () => context.push(
                          AppPaths.bookAppointment,
                          extra: doctor,
                        ),
                        onDoctorTap: () => context.push(
                          AppPaths.doctorDetails,
                          extra: doctor,
                        ),
                      );
                    },
                  ),
        };
      },
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.doctorMeta.copyWith(fontSize: 16),
        ),
      ),
    );
  }
}

Doctor _doctorFrom(AppointmentModel appointment) {
  return Doctor(
    id: appointment.doctorId,
    name: appointment.doctorName,
    specialty: appointment.doctorSpecialty,
    rating: appointment.doctorRating,
    reviewsCount: 0,
    imageUrl: appointment.doctorImageUrl ?? '',
    about: '',
    patientsCount: 0,
    experienceYears: 0,
    workingHours: const [
      WorkingHoursEntry('Monday - Friday', '09:00 am - 06:00 pm'),
    ],
    address: '',
    latitude: 0,
    longitude: 0,
    patientReviews: const <DoctorReview>[],
  );
}

