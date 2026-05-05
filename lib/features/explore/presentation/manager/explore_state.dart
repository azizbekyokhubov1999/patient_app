import '../../../home/domain/entities/hospital.dart';

class ExploreState {
  const ExploreState({
    required this.hospitals,
    required this.userLatitude,
    required this.userLongitude,
    required this.selectedHospitalIndex,
  });

  /// Mock user position (lower Manhattan). Replace with GPS later.
  static const double kDefaultUserLat = 40.7128;
  static const double kDefaultUserLng = -74.006;

  final List<Hospital> hospitals;
  final double userLatitude;
  final double userLongitude;
  final int selectedHospitalIndex;

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
  }) {
    return ExploreState(
      hospitals: hospitals ?? this.hospitals,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      selectedHospitalIndex:
          selectedHospitalIndex ?? this.selectedHospitalIndex,
    );
  }
}
