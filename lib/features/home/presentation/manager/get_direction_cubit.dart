import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'get_direction_state.dart';

/// Demo anchor near lower Manhattan (matches Figma map styling).
const GeoPoint _kDemoHospitalGeo = GeoPoint(40.7128, -74.0060);

class GetDirectionCubit extends Cubit<GetDirectionState> {
  GetDirectionCubit() : super(const GetDirectionInitial());

  Future<void> loadMapData(GeoPoint destination) async {
    emit(const GetDirectionLoading());
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));

      final normalized = _normalizeDestination(destination);
      final userLocation = GeoPoint(
        normalized.latitude + 0.014,
        normalized.longitude - 0.022,
      );

      emit(
        GetDirectionLoaded(
          destination: normalized,
          userLocation: userLocation,
        ),
      );
    } catch (e) {
      emit(GetDirectionError(e.toString()));
    }
  }

  /// Hook for step 2 — route polyline / turn-by-turn (next screen).
  void startNavigation() {
    // Intentionally empty; navigation is triggered from the page via GoRouter.
  }

  GeoPoint _normalizeDestination(GeoPoint point) {
    if (point.latitude.abs() < 1e-4 && point.longitude.abs() < 1e-4) {
      return _kDemoHospitalGeo;
    }
    return point;
  }
}
