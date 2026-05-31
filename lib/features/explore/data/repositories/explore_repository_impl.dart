import '../../domain/repositories/explore_repository.dart';
import '../../../home/domain/entities/hospital.dart';
import '../datasources/explore_remote_data_source.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  ExploreRepositoryImpl(this._remote);

  final ExploreRemoteDataSource _remote;

  @override
  Future<List<Hospital>> getNearbyHospitals() async {
    try {
      return await _remote.fetchNearbyHospitals();
    } catch (e) {
      throw Exception('Failed to fetch nearby hospitals: $e');
    }
  }
}
