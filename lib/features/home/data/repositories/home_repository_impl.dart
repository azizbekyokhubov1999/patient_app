import '../../domain/entities/appointment_preview.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/review_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remote);

  final HomeRemoteDataSource _remote;

  @override
  Future<List<Doctor>> getTopDoctors() => _remote.getTopDoctors();

  @override
  Future<List<Doctor>> getAllDoctors() => _remote.getAllDoctors();

  @override
  Future<List<Hospital>> getNearbyHospitals() => _remote.getNearbyHospitals();

  @override
  Future<List<Hospital>> getAllHospitals() => _remote.getAllHospitals();

  @override
  Future<List<AppointmentPreview>> getUpcomingAppointments(String uid) =>
      _remote.getUpcomingAppointments(uid);

  @override
  Future<List<AppointmentPreview>> getAllUpcomingAppointments(String uid) =>
      _remote.getAllUpcomingAppointments(uid);

  @override
  Future<Hospital?> getHospitalById(String id) => _remote.getHospitalById(id);

  @override
  Future<Hospital?> getHospitalByName(String name) =>
      _remote.getHospitalByName(name);

  @override
  Future<void> submitHospitalReview({
    required String hospitalId,
    required String userId,
    required String userName,
    required String userPhoto,
    required double rating,
    required String comment,
  }) =>
      _remote.submitHospitalReview(
        hospitalId: hospitalId,
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        rating: rating,
        comment: comment,
      );

  @override
  Stream<List<ReviewModel>> getHospitalReviews(String hospitalId) =>
      _remote.getHospitalReviews(hospitalId);

  @override
  Stream<Hospital?> watchHospitalById(String id) =>
      _remote.watchHospitalById(id);
}
