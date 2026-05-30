class LeaveReviewDoctorState {
  const LeaveReviewDoctorState({
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

  LeaveReviewDoctorState copyWith({
    int? rating,
    String? reviewText,
    bool? isSubmitting,
    bool? submitSuccess,
    Object? submitError = _sentinel,
  }) {
    return LeaveReviewDoctorState(
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitError: identical(submitError, _sentinel)
          ? this.submitError
          : submitError as String?,
    );
  }

  static const Object _sentinel = Object();
}
