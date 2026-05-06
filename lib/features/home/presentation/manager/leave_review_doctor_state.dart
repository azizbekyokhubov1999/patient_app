class LeaveReviewDoctorState {
  const LeaveReviewDoctorState({
    required this.rating,
    required this.reviewText,
    required this.isSubmitting,
  });

  final int rating;
  final String reviewText;
  final bool isSubmitting;

  LeaveReviewDoctorState copyWith({
    int? rating,
    String? reviewText,
    bool? isSubmitting,
  }) {
    return LeaveReviewDoctorState(
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
