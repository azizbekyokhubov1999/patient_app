import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/repositories/doctors_repository.dart';
import '../datasources/doctor_remote_data_source.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  DoctorsRepositoryImpl(this._remote);

  final DoctorRemoteDataSource _remote;

  @override
  Future<List<Doctor>> getTopDoctors({
    String? specialty,
    int limit = 30,
  }) {
    return _remote.getTopDoctors(specialty: specialty, limit: limit);
  }

  @override
  Future<List<Doctor>> getFavoriteDoctors() {
    return _remote.getFavoriteDoctors();
  }

  @override
  Future<List<Hospital>> getFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  }) {
    return _remote.getFavoriteHospitals(
      currentLat: currentLat,
      currentLng: currentLng,
    );
  }

  @override
  Future<void> toggleDoctorFavorite({
    required String doctorId,
    required bool isFavorite,
  }) {
    return _remote.setDoctorFavorite(
      doctorId: doctorId,
      isFavorite: isFavorite,
    );
  }

  @override
  Future<void> toggleHospitalFavorite({
    required String hospitalId,
    required bool isFavorite,
  }) {
    return _remote.setHospitalFavorite(
      hospitalId: hospitalId,
      isFavorite: isFavorite,
    );
  }
}
