import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/hospital.dart';
import '../../domain/repositories/home_repository.dart';
import 'nearby_hospitals_state.dart';

class NearbyHospitalsCubit extends Cubit<NearbyHospitalsState> {
  NearbyHospitalsCubit({
    required HomeRepository repository,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _repository = repository,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const NearbyHospitalsInitial());

  final HomeRepository _repository;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> loadNearbyHospitals() async {
    emit(const NearbyHospitalsLoading());

    try {
      final uid = _auth.currentUser?.uid;
      final favoriteIds =
          uid != null ? await _loadFavoriteIds(uid) : <String>{};

      var list = await _repository.getAllHospitals();

      if (favoriteIds.isNotEmpty) {
        list = list
            .map(
              (h) => favoriteIds.contains(h.id)
                  ? h.copyWith(isFavorite: true)
                  : h,
            )
            .toList(growable: false);
      }

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
