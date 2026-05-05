import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/hospital.dart';
import '../../../home/domain/entities/hospital_review.dart';
import 'hospital_details_state.dart';

class HospitalDetailsCubit extends Cubit<HospitalDetailsState> {
  static const String filterVerified = 'Verified';
  static const String filterLatest = 'Latest';
  static const String filterDetailed = 'Detailed Reviews';

  HospitalDetailsCubit(Hospital initialHospital)
    : super(
        HospitalDetailsState(
          hospital: initialHospital,
          selectedTabIndex: 0,
          reviewQuery: '',
          activeReviewFilters: {filterVerified, filterLatest},
        ),
      );

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
