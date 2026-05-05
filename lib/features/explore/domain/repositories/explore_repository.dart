import '../../../home/domain/entities/hospital.dart';

abstract class ExploreRepository {
  Future<List<Hospital>> getNearbyHospitals();
}
