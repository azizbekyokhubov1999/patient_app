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
    final doctorsFuture = _doctorsRepository.getFavoriteDoctors();
    final hospitalsFuture = _doctorsRepository.getFavoriteHospitals(
      currentLat: currentLat,
      currentLng: currentLng,
    );
    final doctors = await doctorsFuture;
    final hospitals = await hospitalsFuture;
    return (doctors: doctors, hospitals: hospitals);
  }
}
