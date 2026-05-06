import '../../../home/domain/entities/doctor.dart';

class LeaveReviewHospitalState {
  const LeaveReviewHospitalState({
    required this.rating,
    required this.selectedSpecialist,
    required this.reviewText,
    required this.isSubmitting,
  });

  final int rating;
  final Doctor? selectedSpecialist;
  final String reviewText;
  final bool isSubmitting;

  LeaveReviewHospitalState copyWith({
    int? rating,
    Doctor? selectedSpecialist,
    String? reviewText,
    bool? isSubmitting,
  }) {
    return LeaveReviewHospitalState(
      rating: rating ?? this.rating,
      selectedSpecialist: selectedSpecialist ?? this.selectedSpecialist,
      reviewText: reviewText ?? this.reviewText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
