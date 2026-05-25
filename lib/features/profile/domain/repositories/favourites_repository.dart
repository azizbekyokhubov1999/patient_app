import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/hospital.dart';

abstract class FavouritesRepository {
  Future<({List<Doctor> doctors, List<Hospital> hospitals})> loadFavourites({
    double currentLat = 0,
    double currentLng = 0,
  });

  Stream<List<Doctor>> watchFavoriteDoctors();

  Stream<List<Hospital>> watchFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  });
}
