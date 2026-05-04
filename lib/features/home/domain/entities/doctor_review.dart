class DoctorReview {
  const DoctorReview({
    required this.authorName,
    required this.avatarUrl,
    required this.verified,
    required this.timeAgo,
    required this.text,
    required this.rating,
    this.imageUrls = const [],
  });

  final String authorName;
  final String avatarUrl;
  final bool verified;
  final String timeAgo;
  final String text;
  final double rating;
  final List<String> imageUrls;
}
