import '../../../home/data/models/review_model.dart';
import '../../../home/domain/entities/hospital.dart';

class HospitalDetailsState {
  const HospitalDetailsState({
    required this.hospital,
    required this.selectedTabIndex,
    required this.reviewQuery,
    required this.activeReviewFilters,
    this.isLoadingSpecialists = false,
    this.reviews = const [],
  });

  final Hospital hospital;
  final int selectedTabIndex;
  final String reviewQuery;
  final Set<String> activeReviewFilters;
  final bool isLoadingSpecialists;
  final List<ReviewModel> reviews;

  HospitalDetailsState copyWith({
    Hospital? hospital,
    int? selectedTabIndex,
    String? reviewQuery,
    Set<String>? activeReviewFilters,
    bool? isLoadingSpecialists,
    List<ReviewModel>? reviews,
  }) {
    return HospitalDetailsState(
      hospital: hospital ?? this.hospital,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      reviewQuery: reviewQuery ?? this.reviewQuery,
      activeReviewFilters: activeReviewFilters ?? this.activeReviewFilters,
      isLoadingSpecialists: isLoadingSpecialists ?? this.isLoadingSpecialists,
      reviews: reviews ?? this.reviews,
    );
  }
}
