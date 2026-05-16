import '../../domain/entities/hospital.dart';

sealed class NearbyHospitalsState {
  const NearbyHospitalsState();
}

final class NearbyHospitalsInitial extends NearbyHospitalsState {
  const NearbyHospitalsInitial();
}

final class NearbyHospitalsLoading extends NearbyHospitalsState {
  const NearbyHospitalsLoading();
}

final class LocationPermissionDenied extends NearbyHospitalsState {
  const LocationPermissionDenied({this.permanent = false});

  final bool permanent;
}

final class NearbyHospitalsLoaded extends NearbyHospitalsState {
  const NearbyHospitalsLoaded({
    required this.hospitals,
    required this.filteredHospitals,
  });

  final List<Hospital> hospitals;
  final List<Hospital> filteredHospitals;
}

final class NearbyHospitalsEmpty extends NearbyHospitalsState {
  const NearbyHospitalsEmpty();
}

final class NearbyHospitalsError extends NearbyHospitalsState {
  const NearbyHospitalsError(this.message);

  final String message;
}
