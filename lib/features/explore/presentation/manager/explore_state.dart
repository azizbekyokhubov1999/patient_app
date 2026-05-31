import '../../../home/domain/entities/hospital.dart';

class ExploreState {
  const ExploreState({
    required this.hospitals,
    required this.userLatitude,
    required this.userLongitude,
    required this.selectedHospitalIndex,
    this.errorMessage,
  });

  /// Mock user position (lower Manhattan). Replace with GPS later.
  static const double kDefaultUserLat = 40.7128;
  static const double kDefaultUserLng = -74.006;

  final List<Hospital> hospitals;
  final double userLatitude;
  final double userLongitude;
  final int selectedHospitalIndex;
  final String? errorMessage;

  Hospital? get selectedHospital {
    if (hospitals.isEmpty) return null;
    final i = selectedHospitalIndex.clamp(0, hospitals.length - 1);
    return hospitals[i];
  }

  ExploreState copyWith({
    List<Hospital>? hospitals,
    double? userLatitude,
    double? userLongitude,
    int? selectedHospitalIndex,
    Object? errorMessage = _sentinel,
  }) {
    return ExploreState(
      hospitals: hospitals ?? this.hospitals,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      selectedHospitalIndex:
          selectedHospitalIndex ?? this.selectedHospitalIndex,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();
}
