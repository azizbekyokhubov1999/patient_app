import '../../data/models/doctor_model.dart';
import '../../data/models/hospital_model.dart';

sealed class FavouritesState {
  const FavouritesState();
}

class FavouritesInitial extends FavouritesState {
  const FavouritesInitial();
}

class FavouritesLoading extends FavouritesState {
  const FavouritesLoading();
}

class FavouritesLoaded extends FavouritesState {
  const FavouritesLoaded({
    required this.favoriteDoctors,
    required this.favoriteHospitals,
  });

  final List<DoctorModel> favoriteDoctors;
  final List<HospitalModel> favoriteHospitals;
}

class FavouritesError extends FavouritesState {
  const FavouritesError(this.message);

  final String message;
}
