/// Applied filter criteria from [FilterPage].
class FilterResult {
  const FilterResult({
    required this.specialist,
    required this.consultationType,
    required this.minRating,
    required this.maxRating,
    required this.minDistance,
    required this.maxDistance,
    required this.minFee,
    required this.maxFee,
  });

  final String specialist;
  final String consultationType;
  final double minRating;
  final double maxRating;
  final double minDistance;
  final double maxDistance;
  final double minFee;
  final double maxFee;

  factory FilterResult.defaults() {
    return const FilterResult(
      specialist: 'All',
      consultationType: 'All',
      minRating: 4.5,
      maxRating: 5.0,
      minDistance: 6,
      maxDistance: 15,
      minFee: 15,
      maxFee: 40,
    );
  }

  FilterResult copyWith({
    String? specialist,
    String? consultationType,
    double? minRating,
    double? maxRating,
    double? minDistance,
    double? maxDistance,
    double? minFee,
    double? maxFee,
  }) {
    return FilterResult(
      specialist: specialist ?? this.specialist,
      consultationType: consultationType ?? this.consultationType,
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      minDistance: minDistance ?? this.minDistance,
      maxDistance: maxDistance ?? this.maxDistance,
      minFee: minFee ?? this.minFee,
      maxFee: maxFee ?? this.maxFee,
    );
  }
}
