import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Demo anchor when Firestore coordinates are unset (matches step-1 map).
const GeoPoint kDemoHospitalGeoPoint = GeoPoint(40.7128, -74.0060);

GeoPoint normalizeHospitalGeoPoint(GeoPoint point) {
  if (point.latitude.abs() < 1e-4 && point.longitude.abs() < 1e-4) {
    return kDemoHospitalGeoPoint;
  }
  return point;
}

LatLng geoToLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);

/// Manhattan-style demo polyline until a directions API is wired in.
List<LatLng> buildDemoRoutePoints(LatLng from, LatLng to) {
  final midLat = (from.latitude + to.latitude) / 2;
  final midLng = (from.longitude + to.longitude) / 2;
  return [
    from,
    LatLng(from.latitude, midLng),
    LatLng(midLat, midLng),
    LatLng(midLat, to.longitude),
    to,
  ];
}

double distanceMeters(GeoPoint a, GeoPoint b) {
  return Geolocator.distanceBetween(
    a.latitude,
    a.longitude,
    b.latitude,
    b.longitude,
  );
}

double? bearingDegrees(LatLng from, LatLng to) {
  const distance = Distance();
  final meters = distance(from, to);
  if (meters < 1) return null;
  return distance.bearing(from, to);
}
