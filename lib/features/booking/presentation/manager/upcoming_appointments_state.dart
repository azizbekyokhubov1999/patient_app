import '../../domain/entities/appointment_model.dart';

sealed class UpcomingAppointmentsState {
  const UpcomingAppointmentsState();
}

final class UpcomingAppointmentsInitial extends UpcomingAppointmentsState {
  const UpcomingAppointmentsInitial();
}

final class UpcomingAppointmentsLoading extends UpcomingAppointmentsState {
  const UpcomingAppointmentsLoading();
}

final class UpcomingAppointmentsLoaded extends UpcomingAppointmentsState {
  const UpcomingAppointmentsLoaded(
    this.appointments, {
    this.appointmentPendingConsultationEnd,
  });

  final List<AppointmentModel> appointments;

  /// Set when a session completes — UI listens and opens feedback.
  final AppointmentModel? appointmentPendingConsultationEnd;

  UpcomingAppointmentsLoaded copyWith({
    List<AppointmentModel>? appointments,
    AppointmentModel? appointmentPendingConsultationEnd,
    bool clearPendingConsultationEnd = false,
  }) {
    return UpcomingAppointmentsLoaded(
      appointments ?? this.appointments,
      appointmentPendingConsultationEnd: clearPendingConsultationEnd
          ? null
          : appointmentPendingConsultationEnd ??
              this.appointmentPendingConsultationEnd,
    );
  }
}

final class UpcomingAppointmentsError extends UpcomingAppointmentsState {
  const UpcomingAppointmentsError(this.message);

  final String message;
}
