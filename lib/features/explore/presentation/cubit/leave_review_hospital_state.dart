class LeaveReviewHospitalState {
  const LeaveReviewHospitalState({
    required this.rating,
    required this.reviewText,
    required this.isSubmitting,
    this.submitSuccess = false,
    this.submitError,
  });

  final int rating;
  final String reviewText;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? submitError;

  LeaveReviewHospitalState copyWith({
    int? rating,
    String? reviewText,
    bool? isSubmitting,
    bool? submitSuccess,
    String? submitError,
  }) {
    return LeaveReviewHospitalState(
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitError: submitError,
    );
  }
}
