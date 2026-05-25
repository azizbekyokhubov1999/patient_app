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
      final doctors = await _doctorsRepository.getTopDoctors(
        specialty: _initialSpecialty,
      );

      if (doctors.isEmpty) {
        emit(const TopSpecialistEmpty());
      } else {
        emit(
          TopSpecialistLoaded(
            doctors: doctors,
            filteredDoctors: List<Doctor>.from(doctors),
          ),
        );
      }
    } catch (e) {
      emit(TopSpecialistError(e.toString()));
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
}
