import '../entities/doctor.dart';
import '../entities/hospital.dart';

abstract class SearchRepository {
  Future<List<Doctor>> getAllDoctors();

  Future<List<Hospital>> getAllHospitals();
}
