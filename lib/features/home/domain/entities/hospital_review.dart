class HospitalReview {
  const HospitalReview({
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.isVerified,
    this.reviewImages = const [],
  });

  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final String createdAt;
  final bool isVerified;
  final List<String> reviewImages;
}
