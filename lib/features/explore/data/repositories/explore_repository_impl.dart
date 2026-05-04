import '../../domain/entities/hospital_explore_model.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_remote_data_source.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  ExploreRepositoryImpl(this._remote);

  final ExploreRemoteDataSource _remote;

  @override
  Future<List<HospitalExploreModel>> getNearbyHospitals() {
    return _remote.fetchNearbyHospitals();
  }
}
