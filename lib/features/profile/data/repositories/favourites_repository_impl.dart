import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/hospital.dart';
import '../../../home/domain/repositories/doctors_repository.dart';
import '../../domain/repositories/favourites_repository.dart';

class FavouritesRepositoryImpl implements FavouritesRepository {
  FavouritesRepositoryImpl(this._doctorsRepository);

  final DoctorsRepository _doctorsRepository;

  @override
  Future<({List<Doctor> doctors, List<Hospital> hospitals})> loadFavourites({
    double currentLat = 0,
    double currentLng = 0,
  }) async {
    final doctors = await _doctorsRepository.getFavoriteDoctors();
    final hospitals = await _doctorsRepository.getFavoriteHospitals(
      currentLat: currentLat,
      currentLng: currentLng,
    );
    return (doctors: doctors, hospitals: hospitals);
  }

  @override
  Stream<List<Doctor>> watchFavoriteDoctors() {
    return _doctorsRepository.watchFavoriteDoctors();
  }

  @override
  Stream<List<Hospital>> watchFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  }) {
    return _doctorsRepository.watchFavoriteHospitals(
      currentLat: currentLat,
      currentLng: currentLng,
    );
  }
}
