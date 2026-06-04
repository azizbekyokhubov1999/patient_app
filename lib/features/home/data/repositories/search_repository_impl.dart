import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/repositories/doctors_repository.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({
    required DoctorsRepository doctorsRepository,
    required HomeRepository homeRepository,
  })  : _doctorsRepository = doctorsRepository,
        _homeRepository = homeRepository;

  final DoctorsRepository _doctorsRepository;
  final HomeRepository _homeRepository;

  @override
  Future<List<Doctor>> getAllDoctors() => _doctorsRepository.getAllDoctors();

  @override
  Future<List<Hospital>> getAllHospitals() =>
      _homeRepository.getAllHospitals();
}
