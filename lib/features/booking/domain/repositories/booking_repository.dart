import '../entities/appointment_model.dart';
import '../entities/time_slot.dart';

abstract class BookingRepository {
  Future<List<TimeSlot>> fetchAvailableSlots({
    required DateTime date,
    required String doctorId,
  });

  Future<List<TimeSlot>> getDoctorSlots(
    String doctorId,
    DateTime selectedDate,
  );

  Future<void> confirmAppointment(Map<String, dynamic> data);

  Stream<List<AppointmentModel>> getUpcomingAppointments();

  Stream<List<AppointmentModel>> getCompletedAppointments();

  Stream<List<AppointmentModel>> getCancelledAppointments();

  Future<void> cancelAppointment(String appointmentId);
}
