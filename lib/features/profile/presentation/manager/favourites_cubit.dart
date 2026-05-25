import 'dart:async';
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

  StreamSubscription<List<DoctorModel>>? _doctorsSubscription;
  StreamSubscription<List<HospitalModel>>? _hospitalsSubscription;
  List<HospitalModel> _latestHospitals = const [];

  Future<void> loadFavourites() async {
    await _doctorsSubscription?.cancel();
    await _hospitalsSubscription?.cancel();
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
      final initial = await _favouritesRepository.loadFavourites();
      _latestHospitals = List<HospitalModel>.from(initial.hospitals);
      emit(
        FavouritesLoaded(
          favoriteDoctors: initial.doctors,
          favoriteHospitals: _latestHospitals,
        ),
      );

      _doctorsSubscription =
          _favouritesRepository.watchFavoriteDoctors().listen(
        (doctors) {
          emit(
            FavouritesLoaded(
              favoriteDoctors: doctors,
              favoriteHospitals: _latestHospitals,
            ),
          );
        },
        onError: (Object e, StackTrace st) {
          developer.log('watchFavoriteDoctors error', error: e, stackTrace: st);
          emit(FavouritesError(e.toString()));
        },
      );

      _hospitalsSubscription =
          _favouritesRepository.watchFavoriteHospitals().listen(
        (hospitals) {
          _latestHospitals = List<HospitalModel>.from(hospitals);
          final current = state;
          if (current is FavouritesLoaded) {
            emit(
              FavouritesLoaded(
                favoriteDoctors: current.favoriteDoctors,
                favoriteHospitals: _latestHospitals,
              ),
            );
          }
        },
        onError: (Object e, StackTrace st) {
          developer.log('watchFavoriteHospitals error', error: e, stackTrace: st);
        },
      );
    } catch (e, st) {
      developer.log('loadFavourites error', error: e, stackTrace: st);
      emit(FavouritesError(e.toString()));
    }
  }

  Future<void> toggleDoctorFavourite(String doctorId) async {
    if (kUseProfileMockData) {
      final current = state;
      if (current is! FavouritesLoaded) return;
      emit(
        FavouritesLoaded(
          favoriteDoctors:
              current.favoriteDoctors.where((d) => d.documentId != doctorId).toList(),
          favoriteHospitals: current.favoriteHospitals,
        ),
      );
      return;
    }

    final trimmedId = doctorId.trim();
    if (trimmedId.isEmpty) return;

    try {
      await _doctorsRepository.toggleDoctorFavorite(
        doctorId: trimmedId,
        isFavorite: false,
      );
    } catch (e, st) {
      developer.log('toggleDoctorFavourite error', error: e, stackTrace: st);
      emit(FavouritesError(e.toString()));
    }
  }

  Future<void> toggleHospitalFavourite(String hospitalId) async {
    if (kUseProfileMockData) {
      final current = state;
      if (current is! FavouritesLoaded) return;
      emit(
        FavouritesLoaded(
          favoriteDoctors: current.favoriteDoctors,
          favoriteHospitals: current.favoriteHospitals
              .where((h) => h.id != hospitalId)
              .toList(),
        ),
      );
      return;
    }

    final trimmedId = hospitalId.trim();
    if (trimmedId.isEmpty) return;

    try {
      await _doctorsRepository.toggleHospitalFavorite(
        hospitalId: trimmedId,
        isFavorite: false,
      );
      final result = await _favouritesRepository.loadFavourites();
      _latestHospitals = List<HospitalModel>.from(result.hospitals);
      final current = state;
      if (current is FavouritesLoaded) {
        emit(
          FavouritesLoaded(
            favoriteDoctors: current.favoriteDoctors,
            favoriteHospitals: _latestHospitals,
          ),
        );
      }
    } catch (e, st) {
      developer.log('toggleHospitalFavourite error', error: e, stackTrace: st);
      emit(FavouritesError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _doctorsSubscription?.cancel();
    _hospitalsSubscription?.cancel();
    return super.close();
  }
}
