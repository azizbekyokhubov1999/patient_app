import '../../domain/entities/hospital_explore_model.dart';

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

  final List<HospitalExploreModel> hospitals;
  final double userLatitude;
  final double userLongitude;
  final int selectedHospitalIndex;

  HospitalExploreModel? get selectedHospital {
    if (hospitals.isEmpty) return null;
    final i = selectedHospitalIndex.clamp(0, hospitals.length - 1);
    return hospitals[i];
  }

  ExploreState copyWith({
    List<HospitalExploreModel>? hospitals,
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
