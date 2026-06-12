import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
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

List<LatLng> buildStraightLineRoute(LatLng from, LatLng to) => [from, to];

/// Fetches a road-following route from the OSRM public API.
Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
  final url = Uri.parse(
    'http://router.project-osrm.org/route/v1/driving/'
    '${start.longitude},${start.latitude};'
    '${end.longitude},${end.latitude}'
    '?overview=full&geometries=geojson',
  );

  final response = await http.get(url).timeout(const Duration(seconds: 15));
  if (response.statusCode != 200) {
    throw Exception('OSRM HTTP ${response.statusCode}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  if (data['code'] != 'Ok') {
    throw Exception('OSRM ${data['code']}');
  }

  final routes = data['routes'] as List<dynamic>?;
  if (routes == null || routes.isEmpty) {
    throw Exception('OSRM no routes');
  }

  final geometry = routes.first['geometry'] as Map<String, dynamic>?;
  final coordinates = geometry?['coordinates'] as List<dynamic>?;
  if (coordinates == null || coordinates.isEmpty) {
    throw Exception('OSRM empty geometry');
  }

  return coordinates
      .map((coord) {
        final pair = coord as List<dynamic>;
        return LatLng(
          (pair[1] as num).toDouble(),
          (pair[0] as num).toDouble(),
        );
      })
      .toList(growable: false);
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
