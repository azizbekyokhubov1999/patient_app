import '../entities/doctor.dart';
import '../entities/hospital.dart';
import '../../data/models/review_model.dart';

abstract class DoctorsRepository {
  Future<Doctor?> getDoctorById(String doctorId);

  Stream<Doctor?> watchDoctorById(String doctorId);

  Future<List<Doctor>> getTopDoctors({String? specialty, int limit = 30});

  Future<List<Doctor>> getAllDoctors();

  Future<List<Doctor>> getHospitalSpecialists(String hospitalId);

  Future<List<Doctor>> getFavoriteDoctors();

  Stream<List<Doctor>> watchFavoriteDoctors();

  Stream<bool> watchDoctorFavorite(String doctorId);

  Future<Set<String>> getFavoriteDoctorIds();

  Future<Set<String>> getFavoriteHospitalIds();

  Future<List<Hospital>> getFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  });

  Stream<List<Hospital>> watchFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  });

  Future<void> toggleDoctorFavorite({
    required String doctorId,
    required bool isFavorite,
  });

  Future<void> submitReview({
    required String doctorId,
    required String userId,
    required String userName,
    required String userPhoto,
    required double rating,
    required String comment,
  });

  Stream<List<ReviewModel>> getDoctorReviews(String doctorId);

  Future<void> toggleHospitalFavorite({
    required String hospitalId,
    required bool isFavorite,
  });
}
