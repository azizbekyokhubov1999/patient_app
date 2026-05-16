import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import 'get_direction_2_state.dart';
import 'get_direction_args.dart';
import 'get_direction_route_helper.dart';

class GetDirection2Cubit extends Cubit<GetDirection2State> {
  GetDirection2Cubit(this._args) : super(const GetDirection2Initial());

  final GetDirectionArgs _args;

  static const double arrivalRadiusMeters = 50;

  StreamSubscription<Position>? _positionSub;
  Timer? _simulationTimer;
  int _simulationIndex = 0;
  List<LatLng> _activeRoute = const [];
  GeoPoint _destination = kDemoHospitalGeoPoint;
  bool _useSimulation = false;

  Future<void> initialize() async {
    emit(const GetDirection2Loading());
    try {
      _destination = normalizeHospitalGeoPoint(_args.geoPoint);
      final user = await _resolveInitialUserLocation(_destination);
      final route = buildDemoRoutePoints(
        geoToLatLng(user),
        geoToLatLng(_destination),
      );
      _activeRoute = route;

      final heading = route.length >= 2
          ? bearingDegrees(route.first, route[1])
          : null;

      emit(
        GetDirection2Loaded(
          args: _args,
          destination: _destination,
          userLocation: user,
          routePoints: route,
          status: GetDirection2NavigationStatus.idle,
          userHeadingDegrees: heading,
        ),
      );

      await _startLocationUpdates();
    } catch (e) {
      emit(GetDirection2Error(e.toString()));
    }
  }

  Future<GeoPoint> _resolveInitialUserLocation(GeoPoint destination) async {
    final live = await _tryReadCurrentPosition();
    if (live != null) return live;
    return GeoPoint(
      destination.latitude + 0.014,
      destination.longitude - 0.022,
    );
  }

  Future<GeoPoint?> _tryReadCurrentPosition() async {
    try {
      var status = await Permission.locationWhenInUse.status;
      if (!status.isGranted) {
        status = await Permission.locationWhenInUse.request();
      }
      if (!status.isGranted) return null;

      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return GeoPoint(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<void> _startLocationUpdates() async {
    await _positionSub?.cancel();
    _simulationTimer?.cancel();
    _useSimulation = false;

    try {
      var status = await Permission.locationWhenInUse.status;
      if (!status.isGranted) {
        status = await Permission.locationWhenInUse.request();
      }
      if (!status.isGranted) {
        _useSimulation = true;
        return;
      }

      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen(
        (position) {
          _applyUserLocation(
            GeoPoint(position.latitude, position.longitude),
            heading: position.heading,
          );
        },
        onError: (_) {
          _useSimulation = true;
        },
      );
    } catch (_) {
      _useSimulation = true;
    }
  }

  void startNavigation() {
    final current = state;
    if (current is! GetDirection2Loaded) return;
    if (current.status == GetDirection2NavigationStatus.navigating) return;

    emit(
      current.copyWith(status: GetDirection2NavigationStatus.navigating),
    );

    // Animate along the demo route when live GPS is unavailable or for
    // presentation; real GPS updates override simulated positions.
    if (_useSimulation) {
      _startRouteSimulation();
    }
  }

  void confirmArrival() => _markArrived();

  void recenterRequested() {
    // Page reads [GetDirection2Loaded.userLocation] after calling this noop.
  }

  void _startRouteSimulation() {
    _simulationTimer?.cancel();
    if (_activeRoute.length < 2) return;

    _simulationIndex = 0;
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final current = state;
      if (current is! GetDirection2Loaded ||
          current.status != GetDirection2NavigationStatus.navigating) {
        return;
      }

      _simulationIndex = (_simulationIndex + 1).clamp(0, _activeRoute.length - 1);
      final point = _activeRoute[_simulationIndex];
      final user = GeoPoint(point.latitude, point.longitude);
      final heading = _simulationIndex < _activeRoute.length - 1
          ? bearingDegrees(point, _activeRoute[_simulationIndex + 1])
          : current.userHeadingDegrees;

      _applyUserLocation(user, heading: heading);

      if (_simulationIndex >= _activeRoute.length - 1) {
        _simulationTimer?.cancel();
      }
    });
  }

  void _applyUserLocation(GeoPoint user, {double? heading}) {
    final current = state;
    if (current is! GetDirection2Loaded) return;

    final resolvedHeading = heading != null && heading >= 0
        ? heading
        : _headingFromRoute(user, current.routePoints) ??
            current.userHeadingDegrees;

    final next = current.copyWith(
      userLocation: user,
      userHeadingDegrees: resolvedHeading,
    );
    emit(next);

    if (distanceMeters(user, _destination) <= arrivalRadiusMeters &&
        next.status == GetDirection2NavigationStatus.navigating) {
      _markArrived();
    }
  }

  double? _headingFromRoute(GeoPoint user, List<LatLng> route) {
    if (route.length < 2) return null;
    final userLatLng = geoToLatLng(user);
    var nearestIndex = 0;
    var nearestDistance = double.infinity;
    for (var i = 0; i < route.length; i++) {
      final d = const Distance().as(
        LengthUnit.Meter,
        userLatLng,
        route[i],
      );
      if (d < nearestDistance) {
        nearestDistance = d;
        nearestIndex = i;
      }
    }
    final nextIndex = (nearestIndex + 1).clamp(0, route.length - 1);
    if (nextIndex == nearestIndex) return null;
    return bearingDegrees(route[nearestIndex], route[nextIndex]);
  }

  void _markArrived() {
    _simulationTimer?.cancel();
    emit(GetDirection2Arrived(args: _args));
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _simulationTimer?.cancel();
    return super.close();
  }
}
