import '../../domain/entities/appointment_model.dart';

sealed class CompletedAppointmentsState {
  const CompletedAppointmentsState();
}

final class CompletedAppointmentsInitial extends CompletedAppointmentsState {
  const CompletedAppointmentsInitial();
}

final class CompletedAppointmentsLoading extends CompletedAppointmentsState {
  const CompletedAppointmentsLoading();
}

final class CompletedAppointmentsLoaded extends CompletedAppointmentsState {
  const CompletedAppointmentsLoaded(this.appointments);

  final List<AppointmentModel> appointments;
}

final class CompletedAppointmentsError extends CompletedAppointmentsState {
  const CompletedAppointmentsError(this.message);

  final String message;
}
