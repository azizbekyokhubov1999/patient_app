import '../../domain/entities/appointment_preview.dart';

sealed class UpcomingAppointmentState {
  const UpcomingAppointmentState();
}

final class UpcomingAppointmentInitial extends UpcomingAppointmentState {
  const UpcomingAppointmentInitial();
}

final class UpcomingAppointmentLoading extends UpcomingAppointmentState {
  const UpcomingAppointmentLoading();
}

final class UpcomingAppointmentLoaded extends UpcomingAppointmentState {
  const UpcomingAppointmentLoaded({
    required this.appointments,
    required this.filteredAppointments,
  });

  final List<AppointmentPreview> appointments;
  final List<AppointmentPreview> filteredAppointments;
}

final class UpcomingAppointmentEmpty extends UpcomingAppointmentState {
  const UpcomingAppointmentEmpty();
}

final class UpcomingAppointmentError extends UpcomingAppointmentState {
  const UpcomingAppointmentError(this.message);

  final String message;
}
