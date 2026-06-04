import '../../domain/entities/appointment_preview.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

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
}
