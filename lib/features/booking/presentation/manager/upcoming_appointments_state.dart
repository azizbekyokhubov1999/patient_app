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
  const UpcomingAppointmentsLoaded(this.appointments);

  final List<AppointmentModel> appointments;
}

final class UpcomingAppointmentsError extends UpcomingAppointmentsState {
  const UpcomingAppointmentsError(this.message);

  final String message;
}
