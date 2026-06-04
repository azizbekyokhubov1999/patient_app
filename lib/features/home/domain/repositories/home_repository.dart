import '../entities/appointment_preview.dart';
import '../entities/doctor.dart';
import '../entities/hospital.dart';

abstract class HomeRepository {
  Future<List<Doctor>> getTopDoctors();

  Future<List<Doctor>> getAllDoctors();

  Future<List<Hospital>> getNearbyHospitals();

  Future<List<Hospital>> getAllHospitals();

  Future<List<AppointmentPreview>> getUpcomingAppointments(String uid);

  Future<List<AppointmentPreview>> getAllUpcomingAppointments(String uid);
}
