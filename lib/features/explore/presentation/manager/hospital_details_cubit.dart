import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/hospital.dart';
import '../../../home/domain/entities/hospital_review.dart';
import '../../../home/domain/repositories/doctors_repository.dart';
import '../../../home/domain/repositories/home_repository.dart';
import 'hospital_details_state.dart';

class HospitalDetailsCubit extends Cubit<HospitalDetailsState> {
  static const String filterVerified = 'Verified';
  static const String filterLatest = 'Latest';
  static const String filterDetailed = 'Detailed Reviews';

  HospitalDetailsCubit({
    required Hospital initialHospital,
    required DoctorsRepository doctorsRepository,
    required HomeRepository homeRepository,
  })  : _doctorsRepository = doctorsRepository,
        _homeRepository = homeRepository,
        super(
          HospitalDetailsState(
            hospital: initialHospital,
            selectedTabIndex: 0,
            reviewQuery: '',
            activeReviewFilters: {filterVerified, filterLatest},
          ),
        ) {
    loadHospitalDetails();
    loadSpecialists();
  }

  final DoctorsRepository _doctorsRepository;
  final HomeRepository _homeRepository;

  Future<void> loadHospitalDetails() async {
    try {
      final hospital = await _homeRepository.getHospitalById(state.hospital.id);
      if (hospital == null) return;

      emit(
        state.copyWith(
          hospital: hospital.copyWith(
            specialists: state.hospital.specialists,
            isFavorite: state.hospital.isFavorite,
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> loadSpecialists() async {
    emit(state.copyWith(isLoadingSpecialists: true));

    try {
      final specialists = await _doctorsRepository.getHospitalSpecialists(
        state.hospital.id,
      );
      emit(
        state.copyWith(
          hospital: state.hospital.copyWith(specialists: specialists),
          isLoadingSpecialists: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          hospital: state.hospital.copyWith(specialists: const []),
          isLoadingSpecialists: false,
        ),
      );
    }
  }

  void setTab(int index) {
    if (index == state.selectedTabIndex) return;
    emit(state.copyWith(selectedTabIndex: index));
  }

  void updateHospital(Hospital hospital) {
    emit(state.copyWith(hospital: hospital));
  }

  List<Doctor> get specialists => state.hospital.specialists;

  void setReviewQuery(String value) {
    emit(state.copyWith(reviewQuery: value));
  }

  void toggleReviewFilter(String filter) {
    final updated = Set<String>.from(state.activeReviewFilters);
    if (updated.contains(filter)) {
      updated.remove(filter);
    } else {
      updated.add(filter);
    }
    emit(state.copyWith(activeReviewFilters: updated));
  }

  List<HospitalReview> get filteredReviews {
    var list = List<HospitalReview>.from(state.hospital.reviews);

    if (state.activeReviewFilters.contains(filterVerified)) {
      list = list.where((r) => r.isVerified).toList();
    }

    if (state.activeReviewFilters.contains(filterDetailed)) {
      list = list.where((r) => r.comment.length >= 80).toList();
    }

    if (state.activeReviewFilters.contains(filterLatest)) {
      list = list.reversed.toList();
    }

    final query = state.reviewQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where(
            (r) =>
                r.userName.toLowerCase().contains(query) ||
                r.comment.toLowerCase().contains(query),
          )
          .toList();
    }

    return list;
  }
}
