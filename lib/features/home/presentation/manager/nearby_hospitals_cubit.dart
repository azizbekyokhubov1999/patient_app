import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/hospital.dart';
import '../../domain/entities/hospital_contact_person.dart';
import '../../domain/entities/hospital_review.dart';
import 'nearby_hospitals_state.dart';

/// Bypass geolocation + Firestore for UI demos.
const bool _kPresentationMockNearby = true;

Hospital _demoHospital({
  required String id,
  required String name,
  required List<String> specialties,
  required String address,
  required double miles,
  required int minutes,
  required double rating,
  required String imageUrl,
  required bool isFavorite,
}) {
  return Hospital(
    id: id,
    name: name,
    rating: rating,
    tags: specialties.join(', '),
    specialties: specialties,
    address: address,
    distance: '${miles.toStringAsFixed(1)} Miles',
    eta: '$minutes Min',
    imageUrl: imageUrl,
    description:
        'Trusted care, modern equipment, and compassionate staff for every patient.',
    treatments: List<String>.from(specialties),
    specialists: const [],
    timings: const {
      'Monday': '08:00 - 20:00',
      'Tuesday': '08:00 - 20:00',
      'Wednesday': '08:00 - 20:00',
      'Thursday': '08:00 - 20:00',
      'Friday': '08:00 - 18:00',
      'Saturday': '09:00 - 14:00',
      'Sunday': 'Closed',
    },
    contactPerson: const HospitalContactPerson(
      name: 'Reception Desk',
      role: 'Care coordinator',
      avatarUrl: 'https://picsum.photos/100/100?random=desk',
    ),
    images: [imageUrl],
    galleryImages: [imageUrl],
    reviews: const <HospitalReview>[],
    latitude: 0,
    longitude: 0,
    distanceInMiles: miles,
    durationInMinutes: minutes,
    isFavorite: isFavorite,
  );
}

List<Hospital> _presentationNearbyHospitals() {
  return [
    _demoHospital(
      id: 'mock-h1',
      name: 'Unity Health Hospital',
      specialties: ['Dentist', 'Ophthalmologist', 'Otology'],
      address: '6391 Elgin St. Celina, Delaware',
      miles: 3.5,
      minutes: 15,
      rating: 4.8,
      imageUrl: 'https://picsum.photos/400/200?random=1',
      isFavorite: true,
    ),
    _demoHospital(
      id: 'mock-h2',
      name: 'EliteCare Hospital',
      specialties: ['Ophthalmologist', 'Orthopaedics'],
      address: '8502 Preston Rd. Inglewood, Maine',
      miles: 4.3,
      minutes: 20,
      rating: 4.9,
      imageUrl: 'https://picsum.photos/400/200?random=2',
      isFavorite: false,
    ),
    _demoHospital(
      id: 'mock-h3',
      name: 'City Medical Center',
      specialties: ['Cardiology', 'Neurology'],
      address: '1901 Thornridge Cir. Shiloh, Hawaii',
      miles: 5.1,
      minutes: 25,
      rating: 4.6,
      imageUrl: 'https://picsum.photos/400/200?random=3',
      isFavorite: false,
    ),
    _demoHospital(
      id: 'mock-h4',
      name: 'Harbor Wellness Clinic',
      specialties: ['Dentistry', 'General Practice'],
      address: '4140 Parker Rd. Allentown, New Mexico',
      miles: 6.2,
      minutes: 28,
      rating: 4.7,
      imageUrl: 'https://picsum.photos/400/200?random=4',
      isFavorite: false,
    ),
  ];
}

/// Platform location setup (required for real mode):
/// - Android: add before `<application>` in `android/app/src/main/AndroidManifest.xml`:
///   `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
///   (and optionally `ACCESS_COARSE_LOCATION`).
/// - iOS: add `NSLocationWhenInUseUsageDescription` to `ios/Runner/Info.plist`.
class NearbyHospitalsCubit extends Cubit<NearbyHospitalsState> {
  NearbyHospitalsCubit({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const NearbyHospitalsInitial());

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  List<Hospital> _presentationSnapshot = const [];
  String _presentationQuery = '';

  NearbyHospitalsLoaded _emitPresentationLoaded() {
    final q = _presentationQuery.trim().toLowerCase();
    final filtered = q.isEmpty
        ? List<Hospital>.from(_presentationSnapshot)
        : _presentationSnapshot
              .where((h) => h.name.toLowerCase().contains(q))
              .toList();
    return NearbyHospitalsLoaded(
      hospitals: List<Hospital>.from(_presentationSnapshot),
      filteredHospitals: filtered,
    );
  }

  Future<void> loadNearbyHospitals() async {
    if (_kPresentationMockNearby) {
      _presentationQuery = '';
      _presentationSnapshot = List<Hospital>.from(_presentationNearbyHospitals())
        ..sort((a, b) => a.distanceInMiles.compareTo(b.distanceInMiles));
      emit(_emitPresentationLoaded());
      return;
    }

    emit(const NearbyHospitalsLoading());
    try {
      var status = await Permission.locationWhenInUse.status;
      if (!status.isGranted) {
        status = await Permission.locationWhenInUse.request();
      }
      if (!status.isGranted) {
        emit(LocationPermissionDenied(permanent: status.isPermanentlyDenied));
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const NearbyHospitalsError('Location services are disabled.'));
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      final snapshot = await _firestore.collection('hospitals').get();

      final uid = _auth.currentUser?.uid;
      final favoriteIds =
          uid != null ? await _loadFavoriteIds(uid) : <String>{};

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        var h = Hospital.fromFirestore(
          data,
          doc.id,
          currentLat: position.latitude,
          currentLng: position.longitude,
        );
        if (favoriteIds.contains(doc.id)) {
          h = h.copyWith(isFavorite: true);
        }
        return h;
      }).toList()
        ..sort((a, b) => a.distanceInMiles.compareTo(b.distanceInMiles));

      if (list.isEmpty) {
        emit(const NearbyHospitalsEmpty());
      } else {
        emit(
          NearbyHospitalsLoaded(
            hospitals: list,
            filteredHospitals: List<Hospital>.from(list),
          ),
        );
      }
    } catch (e) {
      emit(NearbyHospitalsError(e.toString()));
    }
  }

  Future<Set<String>> _loadFavoriteIds(String uid) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();
    return snap.docs.map((d) => d.id).toSet();
  }

  Future<void> refresh() => loadNearbyHospitals();

  Future<void> toggleFavorite(String hospitalId) async {
    final current = state;
    if (current is! NearbyHospitalsLoaded) return;

    Hospital? hospital;
    for (final h in current.hospitals) {
      if (h.id == hospitalId) {
        hospital = h;
        break;
      }
    }
    if (hospital == null) return;

    final nextFavorite = !hospital.isFavorite;

    if (_kPresentationMockNearby) {
      _presentationSnapshot = _presentationSnapshot
          .map(
            (h) =>
                h.id == hospitalId ? h.copyWith(isFavorite: nextFavorite) : h,
          )
          .toList();
      emit(_emitPresentationLoaded());
      return;
    }

    final uid = _auth.currentUser?.uid;

    if (uid != null) {
      final doc = _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(hospitalId);
      try {
        if (nextFavorite) {
          await doc.set({'hospitalId': hospitalId});
        } else {
          await doc.delete();
        }
      } catch (_) {
        return;
      }
    }

    List<Hospital> mapIds(List<Hospital> source) {
      return source
          .map(
            (h) =>
                h.id == hospitalId ? h.copyWith(isFavorite: nextFavorite) : h,
          )
          .toList();
    }

    emit(
      NearbyHospitalsLoaded(
        hospitals: mapIds(current.hospitals),
        filteredHospitals: mapIds(current.filteredHospitals),
      ),
    );
  }

  void filterByQuery(String query) {
    final current = state;
    if (current is! NearbyHospitalsLoaded) return;

    if (_kPresentationMockNearby) {
      _presentationQuery = query;
      emit(_emitPresentationLoaded());
      return;
    }

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      emit(
        NearbyHospitalsLoaded(
          hospitals: current.hospitals,
          filteredHospitals: List<Hospital>.from(current.hospitals),
        ),
      );
      return;
    }

    final filtered = current.hospitals
        .where((h) => h.name.toLowerCase().contains(trimmed))
        .toList();

    emit(
      NearbyHospitalsLoaded(
        hospitals: current.hospitals,
        filteredHospitals: filtered,
      ),
    );
  }
}
