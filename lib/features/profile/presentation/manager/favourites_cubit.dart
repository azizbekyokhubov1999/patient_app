import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/mock_data.dart';
import '../../../home/domain/repositories/doctors_repository.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/hospital_model.dart';
import '../../domain/repositories/favourites_repository.dart';
import 'favourites_state.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  FavouritesCubit({
    required FavouritesRepository favouritesRepository,
    required DoctorsRepository doctorsRepository,
  })  : _favouritesRepository = favouritesRepository,
        _doctorsRepository = doctorsRepository,
        super(const FavouritesInitial());

  final FavouritesRepository _favouritesRepository;
  final DoctorsRepository _doctorsRepository;

  Future<void> loadFavourites() async {
    emit(const FavouritesLoading());

    if (kUseProfileMockData) {
      emit(
        FavouritesLoaded(
          favoriteDoctors: List<DoctorModel>.from(mockFavoriteDoctors),
          favoriteHospitals: List<HospitalModel>.from(mockFavoriteHospitals),
        ),
      );
      return;
    }

    try {
      final result = await _favouritesRepository.loadFavourites();
      emit(
        FavouritesLoaded(
          favoriteDoctors: result.doctors,
          favoriteHospitals: result.hospitals,
        ),
      );
    } catch (e, st) {
      developer.log('loadFavourites error', error: e, stackTrace: st);
      emit(FavouritesError(e.toString()));
    }
  }

  Future<void> toggleDoctorFavourite(String doctorId) async {
    final current = state;
    if (current is! FavouritesLoaded) return;

    final exists = current.favoriteDoctors.any((d) => d.id == doctorId);
    if (!exists) return;

    final updatedDoctors =
        current.favoriteDoctors.where((d) => d.id != doctorId).toList();
    emit(
      FavouritesLoaded(
        favoriteDoctors: updatedDoctors,
        favoriteHospitals: current.favoriteHospitals,
      ),
    );

    if (kUseProfileMockData) return;

    try {
      await _doctorsRepository.toggleDoctorFavorite(
        doctorId: doctorId,
        isFavorite: false,
      );
    } catch (e, st) {
      developer.log('toggleDoctorFavourite error', error: e, stackTrace: st);
      await loadFavourites();
    }
  }

  Future<void> toggleHospitalFavourite(String hospitalId) async {
    final current = state;
    if (current is! FavouritesLoaded) return;

    final exists = current.favoriteHospitals.any((h) => h.id == hospitalId);
    if (!exists) return;

    final updatedHospitals =
        current.favoriteHospitals.where((h) => h.id != hospitalId).toList();
    emit(
      FavouritesLoaded(
        favoriteDoctors: current.favoriteDoctors,
        favoriteHospitals: updatedHospitals,
      ),
    );

    if (kUseProfileMockData) return;

    try {
      await _doctorsRepository.toggleHospitalFavorite(
        hospitalId: hospitalId,
        isFavorite: false,
      );
    } catch (e, st) {
      developer.log('toggleHospitalFavourite error', error: e, stackTrace: st);
      await loadFavourites();
    }
  }
}
