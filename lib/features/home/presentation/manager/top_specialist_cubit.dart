import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/doctor.dart';
import '../../domain/repositories/doctors_repository.dart';
import 'top_specialist_state.dart';

class TopSpecialistCubit extends Cubit<TopSpecialistState> {
  TopSpecialistCubit({
    required DoctorsRepository doctorsRepository,
    String? initialSpecialty,
  })  : _doctorsRepository = doctorsRepository,
        _initialSpecialty = initialSpecialty,
        super(const TopSpecialistInitial());

  final DoctorsRepository _doctorsRepository;
  final String? _initialSpecialty;

  Future<void> loadTopSpecialists() async {
    emit(const TopSpecialistLoading());

    try {
      final favoriteIds = await _doctorsRepository.getFavoriteDoctorIds();
      final doctors = await _doctorsRepository.getTopDoctors(
        specialty: _initialSpecialty,
      );
      final withFavorites = _applyFavoriteFlags(doctors, favoriteIds);

      if (withFavorites.isEmpty) {
        emit(const TopSpecialistEmpty());
      } else {
        emit(
          TopSpecialistLoaded(
            doctors: withFavorites,
            filteredDoctors: List<Doctor>.from(withFavorites),
          ),
        );
      }
    } catch (e) {
      emit(TopSpecialistError(e.toString()));
    }
  }

  Future<void> toggleDoctorFavorite(String doctorId) async {
    final current = state;
    if (current is! TopSpecialistLoaded) return;

    Doctor? doctor;
    for (final d in current.doctors) {
      if (d.documentId == doctorId) {
        doctor = d;
        break;
      }
    }
    if (doctor == null) return;

    final nextFavorite = !doctor.isFavorite;

    List<Doctor> mapFavorite(List<Doctor> source) {
      return source
          .map(
            (d) => d.documentId == doctorId
                ? d.copyWith(isFavorite: nextFavorite)
                : d,
          )
          .toList();
    }

    final optimistic = TopSpecialistLoaded(
      doctors: mapFavorite(current.doctors),
      filteredDoctors: mapFavorite(current.filteredDoctors),
    );
    emit(optimistic);

    try {
      await _doctorsRepository.toggleDoctorFavorite(
        doctorId: doctorId,
        isFavorite: nextFavorite,
      );
    } catch (_) {
      emit(current);
    }
  }

  void filterByQuery(String query) {
    final current = state;
    if (current is! TopSpecialistLoaded) return;

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      clearFilter();
      return;
    }

    final filtered = current.doctors.where((d) {
      final name = d.name.toLowerCase();
      final spec = d.specialty.toLowerCase();
      return name.contains(trimmed) || spec.contains(trimmed);
    }).toList();

    emit(
      TopSpecialistLoaded(
        doctors: current.doctors,
        filteredDoctors: filtered,
      ),
    );
  }

  void clearFilter() {
    final current = state;
    if (current is! TopSpecialistLoaded) return;
    emit(
      TopSpecialistLoaded(
        doctors: current.doctors,
        filteredDoctors: List<Doctor>.from(current.doctors),
      ),
    );
  }

  Future<void> refresh() => loadTopSpecialists();

  List<Doctor> _applyFavoriteFlags(List<Doctor> doctors, Set<String> ids) {
    return doctors
        .map(
          (doctor) => doctor.copyWith(
            isFavorite: ids.contains(doctor.documentId),
          ),
        )
        .toList();
  }
}
