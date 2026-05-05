import '../../../home/domain/entities/hospital.dart';

class HospitalDetailsState {
  const HospitalDetailsState({
    required this.hospital,
    required this.selectedTabIndex,
    required this.reviewQuery,
    required this.activeReviewFilters,
  });

  final Hospital hospital;
  final int selectedTabIndex;
  final String reviewQuery;
  final Set<String> activeReviewFilters;

  HospitalDetailsState copyWith({
    Hospital? hospital,
    int? selectedTabIndex,
    String? reviewQuery,
    Set<String>? activeReviewFilters,
  }) {
    return HospitalDetailsState(
      hospital: hospital ?? this.hospital,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      reviewQuery: reviewQuery ?? this.reviewQuery,
      activeReviewFilters: activeReviewFilters ?? this.activeReviewFilters,
    );
  }
}
