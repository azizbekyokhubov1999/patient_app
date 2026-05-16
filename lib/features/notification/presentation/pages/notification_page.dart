import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../booking/domain/entities/package_type.dart';
import '../../../booking/domain/entities/patient_info.dart';
import '../../../booking/presentation/models/booking_route_args.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/doctor_review.dart';
import '../../../home/domain/entities/working_hours_entry.dart';
import '../../domain/entities/notification_model.dart';
import '../../domain/entities/notification_type.dart';
import '../manager/notification_cubit.dart';
import '../manager/notification_state.dart';
import '../widgets/notification_group_header.dart';
import '../widgets/notification_item.dart';

Doctor _doctorForReview(NotificationModel notification) {
  final name = (notification.relatedId != null &&
          notification.relatedId!.isNotEmpty)
      ? notification.relatedId!.replaceAll('_', ' ')
      : 'Doctor';
  return Doctor(
    name: name,
    specialty: '',
    rating: 0,
    reviewsCount: 0,
    imageUrl: '',
    about: '',
    patientsCount: 0,
    experienceYears: 0,
    workingHours: const <WorkingHoursEntry>[],
    address: '',
    latitude: 0,
    longitude: 0,
    patientReviews: const <DoctorReview>[],
  );
}

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  void _handleTap(BuildContext context, NotificationModel n) {
    unawaited(context.read<NotificationCubit>().markNotificationAsRead(n.id));

    switch (n.type) {
      case NotificationType.appointmentConfirmed:
      case NotificationType.videoCallAppointment:
      case NotificationType.appointmentReminder:
        context.push(AppPaths.appointments);
        return;
      case NotificationType.ratingRequested:
        context.push(
          AppPaths.leaveReview,
          extra: _doctorForReview(n),
        );
        return;
      case NotificationType.paymentMethodAdded:
        context.push(
          AppPaths.paymentMethods,
          extra: PaymentMethodArgs(
            selectedDate: DateTime.now(),
            selectedTime: '10:00',
            selectedPackage: PackageType.messaging,
            patientInfo: const PatientInfo(
              isForSelf: true,
              name: '—',
              gender: '—',
              age: '—',
              problemDescription: '—',
            ),
            doctorId: n.relatedId,
          ),
        );
        return;
      case NotificationType.scheduleReminder:
        context.push(AppPaths.appointments);
        return;
      case NotificationType.systemUpdate:
        context.push(AppPaths.explore);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final grouped = state.groupedNotifications;
        final labels = NotificationCubit.sortedGroupLabels(grouped);
        final hasRows = grouped.values.any((list) => list.isNotEmpty);

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
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
                    LucideIcons.arrowLeft,
                    size: 20,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),
            centerTitle: true,
            title: Text(
              'Notification',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              if (state.unreadCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.unreadCount} NEW',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: state.isLoading && !hasRows
              ? const Center(child: CircularProgressIndicator())
              : state.errorMessage != null && !hasRows
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    )
                  : !hasRows
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.bellOff,
                                size: 64,
                                color: AppColors.secondaryText.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No notifications yet',
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _itemCount(labels, grouped),
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.stroke,
                          ),
                          itemBuilder: (context, index) {
                            return _buildItem(
                              context,
                              index,
                              labels,
                              grouped,
                            );
                          },
                        ),
        );
      },
    );
  }

  int _itemCount(
    List<String> labels,
    Map<String, List<NotificationModel>> grouped,
  ) {
    var count = 0;
    for (final label in labels) {
      count += 1; // header row
      count += grouped[label]?.length ?? 0;
    }
    return count;
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    List<String> labels,
    Map<String, List<NotificationModel>> grouped,
  ) {
    var cursor = 0;
    for (final label in labels) {
      final items = grouped[label] ?? const <NotificationModel>[];

      if (cursor == index) {
        return NotificationGroupHeader(
          groupLabel: label,
          onMarkAllRead: () => context
              .read<NotificationCubit>()
              .markGroupAsRead(label),
        );
      }
      cursor++;

      for (final n in items) {
        if (cursor == index) {
          return NotificationItem(
            notification: n,
            onTap: () => _handleTap(context, n),
          );
        }
        cursor++;
      }
    }
    return const SizedBox.shrink();
  }
}
