import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/repositories/doctors_repository.dart';
import '../datasources/doctor_remote_data_source.dart';
import '../models/review_model.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  DoctorsRepositoryImpl(this._remote);

  final DoctorRemoteDataSource _remote;

  @override
  Future<Doctor?> getDoctorById(String doctorId) {
    return _remote.getDoctorById(doctorId);
  }

  @override
  Stream<Doctor?> watchDoctorById(String doctorId) {
    return _remote.watchDoctorById(doctorId);
  }

  @override
  Future<List<Doctor>> getTopDoctors({
    String? specialty,
    int limit = 30,
  }) {
    return _remote.getTopDoctors(specialty: specialty, limit: limit);
  }

  @override
  Future<List<Doctor>> getAllDoctors() => _remote.getAllDoctors();

  @override
  Future<List<Doctor>> getHospitalSpecialists(String hospitalId) =>
      _remote.getHospitalSpecialists(hospitalId);

  @override
  Future<List<Doctor>> getFavoriteDoctors() {
    return _remote.getFavoriteDoctors();
  }

  @override
  Stream<List<Doctor>> watchFavoriteDoctors() {
    return _remote.watchFavoriteDoctors();
  }

  @override
  Stream<bool> watchDoctorFavorite(String doctorId) {
    return _remote.watchDoctorFavorite(doctorId);
  }

  @override
  Future<Set<String>> getFavoriteDoctorIds() => _remote.getFavoriteDoctorIds();

  @override
  Future<Set<String>> getFavoriteHospitalIds() =>
      _remote.getFavoriteHospitalIds();

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
  Stream<List<Hospital>> watchFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  }) {
    return _remote.watchFavoriteHospitals(
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
  Future<void> submitReview({
    required String doctorId,
    required String userId,
    required String userName,
    required String userPhoto,
    required double rating,
    required String comment,
  }) {
    return _remote.submitReview(
      doctorId: doctorId,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      rating: rating,
      comment: comment,
    );
  }

  @override
  Stream<List<ReviewModel>> getDoctorReviews(String doctorId) {
    return _remote.getDoctorReviews(doctorId);
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
