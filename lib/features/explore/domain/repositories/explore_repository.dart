import '../entities/hospital_explore_model.dart';

abstract class ExploreRepository {
  Future<List<HospitalExploreModel>> getNearbyHospitals();
}
