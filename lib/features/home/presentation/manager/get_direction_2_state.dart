import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import 'get_direction_args.dart';

enum GetDirection2NavigationStatus { idle, navigating, arrived }

sealed class GetDirection2State {
  const GetDirection2State();
}

final class GetDirection2Initial extends GetDirection2State {
  const GetDirection2Initial();
}

final class GetDirection2Loading extends GetDirection2State {
  const GetDirection2Loading();
}

final class GetDirection2Loaded extends GetDirection2State {
  const GetDirection2Loaded({
    required this.args,
    required this.destination,
    required this.userLocation,
    required this.routePoints,
    required this.status,
    this.userHeadingDegrees,
  });

  final GetDirectionArgs args;
  final GeoPoint destination;
  final GeoPoint userLocation;
  final List<LatLng> routePoints;
  final GetDirection2NavigationStatus status;
  final double? userHeadingDegrees;

  String get hospitalAddress =>
      args.hospitalAddress?.trim().isNotEmpty == true
          ? args.hospitalAddress!.trim()
          : '2464 Royal Ln. Mesa, New Jersey 45463';

  bool get isNavigating => status == GetDirection2NavigationStatus.navigating;

  GetDirection2Loaded copyWith({
    GeoPoint? destination,
    GeoPoint? userLocation,
    List<LatLng>? routePoints,
    GetDirection2NavigationStatus? status,
    double? userHeadingDegrees,
  }) {
    return GetDirection2Loaded(
      args: args,
      destination: destination ?? this.destination,
      userLocation: userLocation ?? this.userLocation,
      routePoints: routePoints ?? this.routePoints,
      status: status ?? this.status,
      userHeadingDegrees: userHeadingDegrees ?? this.userHeadingDegrees,
    );
  }
}

final class GetDirection2Arrived extends GetDirection2State {
  const GetDirection2Arrived({required this.args});

  final GetDirectionArgs args;
}

final class GetDirection2Error extends GetDirection2State {
  const GetDirection2Error(this.message);

  final String message;
}
