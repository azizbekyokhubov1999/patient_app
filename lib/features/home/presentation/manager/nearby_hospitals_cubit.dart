import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/hospital.dart';
import '../../domain/repositories/doctors_repository.dart';
import '../../domain/repositories/home_repository.dart';
import 'nearby_hospitals_state.dart';

class NearbyHospitalsCubit extends Cubit<NearbyHospitalsState> {
  NearbyHospitalsCubit({
    required HomeRepository repository,
    required DoctorsRepository doctorsRepository,
  })  : _repository = repository,
        _doctorsRepository = doctorsRepository,
        super(const NearbyHospitalsInitial());

  final HomeRepository _repository;
  final DoctorsRepository _doctorsRepository;

  Future<void> loadNearbyHospitals() async {
    emit(const NearbyHospitalsLoading());

    try {
      final favoriteIds = await _doctorsRepository.getFavoriteHospitalIds();
      final list = (await _repository.getAllHospitals())
          .map(
            (hospital) => hospital.copyWith(
              isFavorite: favoriteIds.contains(hospital.id),
            ),
          )
          .toList(growable: false);

      if (list.isEmpty) {
        emit(const NearbyHospitalsEmpty());
      } else {
        emit(
          NearbyHospitalsLoaded(
            hospitals: list,
            filteredHospitals: List<Hospital>.from(list),
          ),
        );
      }
    } catch (e) {
      emit(NearbyHospitalsError(e.toString()));
    }
  }

  Future<void> refresh() => loadNearbyHospitals();

  Future<void> toggleFavorite(String hospitalId) async {
    final current = state;
    if (current is! NearbyHospitalsLoaded) return;

    Hospital? hospital;
    for (final h in current.hospitals) {
      if (h.id == hospitalId) {
        hospital = h;
        break;
      }
    }
    if (hospital == null) return;

    final nextFavorite = !hospital.isFavorite;

    List<Hospital> mapFavorite(List<Hospital> source) {
      return source
          .map(
            (h) =>
                h.id == hospitalId ? h.copyWith(isFavorite: nextFavorite) : h,
          )
          .toList();
    }

    final optimistic = NearbyHospitalsLoaded(
      hospitals: mapFavorite(current.hospitals),
      filteredHospitals: mapFavorite(current.filteredHospitals),
    );
    emit(optimistic);

    try {
      await _doctorsRepository.toggleHospitalFavorite(
        hospitalId: hospitalId,
        isFavorite: nextFavorite,
      );
    } catch (_) {
      emit(current);
    }
  }

  void filterByQuery(String query) {
    final current = state;
    if (current is! NearbyHospitalsLoaded) return;

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      emit(
        NearbyHospitalsLoaded(
          hospitals: current.hospitals,
          filteredHospitals: List<Hospital>.from(current.hospitals),
        ),
      );
      return;
    }

    final filtered = current.hospitals
        .where((h) => h.name.toLowerCase().contains(trimmed))
        .toList();

    emit(
      NearbyHospitalsLoaded(
        hospitals: current.hospitals,
        filteredHospitals: filtered,
      ),
    );
  }
}
