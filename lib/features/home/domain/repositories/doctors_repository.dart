import '../entities/doctor.dart';
import '../entities/hospital.dart';

abstract class DoctorsRepository {
  Future<Doctor?> getDoctorById(String doctorId);

  Future<List<Doctor>> getTopDoctors({String? specialty, int limit = 30});

  Future<List<Doctor>> getFavoriteDoctors();

  Stream<List<Doctor>> watchFavoriteDoctors();

  Stream<bool> watchDoctorFavorite(String doctorId);

  Future<List<Hospital>> getFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  });

  Future<void> toggleDoctorFavorite({
    required String doctorId,
    required bool isFavorite,
  });

  Future<void> toggleHospitalFavorite({
    required String hospitalId,
    required bool isFavorite,
  });
}
