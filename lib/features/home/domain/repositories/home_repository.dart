import '../entities/appointment_preview.dart';
import '../entities/doctor.dart';
import '../entities/hospital.dart';
import '../../data/models/review_model.dart';

abstract class HomeRepository {
  Future<List<Doctor>> getTopDoctors();

  Future<List<Doctor>> getAllDoctors();

  Future<List<Hospital>> getNearbyHospitals();

  Future<List<Hospital>> getAllHospitals();

  Future<List<AppointmentPreview>> getUpcomingAppointments(String uid);

  Future<List<AppointmentPreview>> getAllUpcomingAppointments(String uid);

  Future<Hospital?> getHospitalById(String id);

  Future<Hospital?> getHospitalByName(String name);

  Future<void> submitHospitalReview({
    required String hospitalId,
    required String userId,
    required String userName,
    required String userPhoto,
    required double rating,
    required String comment,
  });

  Stream<List<ReviewModel>> getHospitalReviews(String hospitalId);

  Stream<Hospital?> watchHospitalById(String id);
}
