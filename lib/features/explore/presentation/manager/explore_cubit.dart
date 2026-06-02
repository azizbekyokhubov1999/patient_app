import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/repositories/explore_repository.dart';
import 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit(this._repository)
    : super(
        const ExploreState(
          hospitals: [],
          userLatitude: ExploreState.kDefaultUserLat,
          userLongitude: ExploreState.kDefaultUserLng,
          selectedHospitalIndex: 0,
        ),
      );

  final ExploreRepository _repository;

  Future<void> load() async {
    final (userLat, userLng) = await _resolveUserLocation();

    try {
      final hospitals = await _repository.getNearbyHospitals();
      emit(
        state.copyWith(
          hospitals: hospitals,
          userLatitude: userLat,
          userLongitude: userLng,
          selectedHospitalIndex: 0,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          hospitals: const [],
          userLatitude: userLat,
          userLongitude: userLng,
          selectedHospitalIndex: 0,
          errorMessage: 'Failed to load hospitals. Please try again.',
        ),
      );
    }
  }

  Future<(double, double)> _resolveUserLocation() async {
    try {
      final gps = await _tryGpsLocation();
      if (gps != null) return gps;

      final firestore = await _tryFirestoreLocation();
      if (firestore != null) return firestore;
    } catch (_) {
      // Fall through to default coordinates.
    }

    return (ExploreState.kDefaultUserLat, ExploreState.kDefaultUserLng);
  }

  Future<(double, double)?> _tryGpsLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return (position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<(double, double)?> _tryFirestoreLocation() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data == null) return null;

      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      if (lat == 0 && lng == 0) return null;

      return (lat, lng);
    } catch (_) {
      return null;
    }
  }

  void selectHospital(int index) {
    if (state.hospitals.isEmpty) return;
    if (index < 0 || index >= state.hospitals.length) return;
    if (index == state.selectedHospitalIndex) return;
    emit(state.copyWith(selectedHospitalIndex: index));
  }
}
