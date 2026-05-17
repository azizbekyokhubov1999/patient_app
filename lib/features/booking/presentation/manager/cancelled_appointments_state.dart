import '../../domain/entities/appointment_model.dart';

sealed class CancelledAppointmentsState {
  const CancelledAppointmentsState();
}

final class CancelledAppointmentsInitial extends CancelledAppointmentsState {
  const CancelledAppointmentsInitial();
}

final class CancelledAppointmentsLoading extends CancelledAppointmentsState {
  const CancelledAppointmentsLoading();
}

final class CancelledAppointmentsLoaded extends CancelledAppointmentsState {
  const CancelledAppointmentsLoaded(this.appointments);

  final List<AppointmentModel> appointments;
}

final class CancelledAppointmentsError extends CancelledAppointmentsState {
  const CancelledAppointmentsError(this.message);

  final String message;
}
