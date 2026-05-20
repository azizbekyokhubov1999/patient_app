import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/mock_data.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/hospital.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/hospital_model.dart';
import 'favourites_state.dart';

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

    if (kUseProfileMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      emit(
        FavouritesLoaded(
          favoriteDoctors: List<DoctorModel>.from(mockFavoriteDoctors),
          favoriteHospitals: List<HospitalModel>.from(mockFavoriteHospitals),
        ),
      );
      return;
    }

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(const FavouritesError('No signed-in user'));
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

    final exists = current.favoriteDoctors.any((d) => d.id == doctorId);
    if (!exists) return;

    final updatedDoctors =
        current.favoriteDoctors.where((d) => d.id != doctorId).toList();
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

    final exists = current.favoriteHospitals.any((h) => h.id == hospitalId);
    if (!exists) return;

    final updatedHospitals =
        current.favoriteHospitals.where((h) => h.id != hospitalId).toList();
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
    if (kUseProfileMockData) return;

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
}
