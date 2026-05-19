import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/doctor_review.dart';
import '../../../home/domain/entities/hospital.dart';
import '../../../home/domain/entities/hospital_contact_person.dart';
import '../../../home/domain/entities/hospital_review.dart';
import '../../../home/domain/entities/working_hours_entry.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/hospital_model.dart';
import 'favourites_state.dart';

const bool _kPresentationMockFavourites = true;

class FavouritesCubit extends Cubit<FavouritesState> {
  FavouritesCubit({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const FavouritesInitial());

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> loadFavourites() async {
    emit(const FavouritesLoading());

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(const FavouritesError('No signed-in user'));
        return;
      }

      if (_kPresentationMockFavourites) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        emit(
          FavouritesLoaded(
            favoriteDoctors: _mockDoctors(),
            favoriteHospitals: _mockHospitals(),
          ),
        );
        return;
      }

      final doctorIds = await _loadFavoriteIds(uid, 'favorite_doctors');
      final hospitalIds = await _loadFavoriteIds(uid, 'favorite_hospitals');

      final doctors = await _fetchDoctors(doctorIds);
      final hospitals = await _fetchHospitals(hospitalIds);

      emit(
        FavouritesLoaded(
          favoriteDoctors: doctors,
          favoriteHospitals: hospitals,
        ),
      );
    } catch (e, st) {
      developer.log('loadFavourites error', error: e, stackTrace: st);
      emit(FavouritesError(e.toString()));
    }
  }

  Future<void> toggleDoctorFavourite(String doctorId) async {
    final current = state;
    if (current is! FavouritesLoaded) return;

    final exists =
        current.favoriteDoctors.any((d) => d.id == doctorId);
    if (!exists) return;

    final updatedDoctors = current.favoriteDoctors
        .where((d) => d.id != doctorId)
        .toList();
    emit(
      FavouritesLoaded(
        favoriteDoctors: updatedDoctors,
        favoriteHospitals: current.favoriteHospitals,
      ),
    );

    await _deleteFavorite(
      collection: 'favorite_doctors',
      itemId: doctorId,
    );
  }

  Future<void> toggleHospitalFavourite(String hospitalId) async {
    final current = state;
    if (current is! FavouritesLoaded) return;

    final exists =
        current.favoriteHospitals.any((h) => h.id == hospitalId);
    if (!exists) return;

    final updatedHospitals = current.favoriteHospitals
        .where((h) => h.id != hospitalId)
        .toList();
    emit(
      FavouritesLoaded(
        favoriteDoctors: current.favoriteDoctors,
        favoriteHospitals: updatedHospitals,
      ),
    );

    await _deleteFavorite(
      collection: 'favorite_hospitals',
      itemId: hospitalId,
    );
  }

  Future<Set<String>> _loadFavoriteIds(String uid, String collection) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection(collection)
        .get();
    return snap.docs.map((d) => d.id).toSet();
  }

  Future<List<DoctorModel>> _fetchDoctors(Set<String> ids) async {
    if (ids.isEmpty) return const [];

    final futures = ids.map((id) async {
      final doc = await _firestore.collection('doctors').doc(id).get();
      if (!doc.exists) return null;
      return Doctor.fromFirestore(doc.data() ?? {}, doc.id);
    });

    final results = await Future.wait(futures);
    return results.whereType<Doctor>().toList();
  }

  Future<List<HospitalModel>> _fetchHospitals(Set<String> ids) async {
    if (ids.isEmpty) return const [];

    final futures = ids.map((id) async {
      final doc = await _firestore.collection('hospitals').doc(id).get();
      if (!doc.exists) return null;
      return Hospital.fromFirestore(
        doc.data() ?? {},
        doc.id,
        currentLat: 0,
        currentLng: 0,
      );
    });

    final results = await Future.wait(futures);
    return results.whereType<Hospital>().toList();
  }

  Future<void> _deleteFavorite({
    required String collection,
    required String itemId,
  }) async {
    if (_kPresentationMockFavourites) return;

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection(collection)
          .doc(itemId)
          .delete();
    } catch (e, st) {
      developer.log('toggle favourite delete error', error: e, stackTrace: st);
      await loadFavourites();
    }
  }

  List<DoctorModel> _mockDoctors() {
    return [
      _demoDoctor(
        id: 'mock-dr-rossi',
        name: 'Dr. Sophia Rossi',
        specialty: 'Otology Specialist',
        rating: 4.9,
        reviewsCount: 53,
      ),
      _demoDoctor(
        id: 'mock-dr-fox',
        name: 'Dr. Robert Fox',
        specialty: 'Dentist',
        rating: 5,
        reviewsCount: 12,
      ),
      _demoDoctor(
        id: 'mock-dr-chen',
        name: 'Dr. James Chen',
        specialty: 'Radiologist',
        rating: 4.9,
        reviewsCount: 49,
      ),
    ];
  }

  List<HospitalModel> _mockHospitals() {
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
      ),
    ];
  }
}

Doctor _demoDoctor({
  required String id,
  required String name,
  required String specialty,
  required double rating,
  required int reviewsCount,
}) {
  return Doctor(
    id: id,
    name: name,
    specialty: specialty,
    rating: rating,
    reviewsCount: reviewsCount,
    imageUrl: 'https://picsum.photos/200?doctor=$id',
    about: '$name provides compassionate, patient-first care.',
    patientsCount: 900 + reviewsCount * 4,
    experienceYears: 10,
    workingHours: const [
      WorkingHoursEntry('Monday - Friday', '09:00 am - 06:00 pm'),
    ],
    address: '4140 Parker Rd., San Francisco',
    latitude: 37.77,
    longitude: -122.42,
    patientReviews: const <DoctorReview>[],
  );
}

Hospital _demoHospital({
  required String id,
  required String name,
  required List<String> specialties,
  required String address,
  required double miles,
  required int minutes,
  required double rating,
  required String imageUrl,
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
    description: 'Trusted care with modern facilities.',
    treatments: List<String>.from(specialties),
    specialists: const [],
    timings: const {'Monday': '08:00 - 20:00'},
    contactPerson: const HospitalContactPerson(
      name: 'Reception',
      role: 'Coordinator',
      avatarUrl: '',
    ),
    images: [imageUrl],
    galleryImages: [imageUrl],
    reviews: const <HospitalReview>[],
    latitude: 37.78,
    longitude: -122.41,
    distanceInMiles: miles,
    durationInMinutes: minutes,
    isFavorite: true,
  );
}
