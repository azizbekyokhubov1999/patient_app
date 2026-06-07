import 'dart:async';
import 'dart:math' show min;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import '../models/doctor_model.dart';
import '../models/review_model.dart';

abstract class DoctorRemoteDataSource {
  Future<Doctor?> getDoctorById(String doctorId);

  Stream<Doctor?> watchDoctorById(String doctorId);

  Future<List<Doctor>> getTopDoctors({String? specialty, int limit = 30});

  Future<List<Doctor>> getAllDoctors();

  Future<List<Doctor>> getHospitalSpecialists(String hospitalId);

  Future<List<Doctor>> getFavoriteDoctors();

  Stream<List<Doctor>> watchFavoriteDoctors();

  Future<List<Hospital>> getFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  });

  Stream<List<Hospital>> watchFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  });

  Future<void> setDoctorFavorite({
    required String doctorId,
    required bool isFavorite,
  });

  Stream<bool> watchDoctorFavorite(String doctorId);

  Future<Set<String>> getFavoriteDoctorIds();

  Future<Set<String>> getFavoriteHospitalIds();

  Future<void> submitReview({
    required String doctorId,
    required String userId,
    required String userName,
    required String userPhoto,
    required double rating,
    required String comment,
  });

  Stream<List<ReviewModel>> getDoctorReviews(String doctorId);

  Future<void> setHospitalFavorite({
    required String hospitalId,
    required bool isFavorite,
  });
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  DoctorRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _favoriteDoctorIdsField = 'favoriteDoctorIds';
  static const String _favoriteHospitalIdsField = 'favoriteHospitalIds';

  String get _uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  @override
  Future<Doctor?> getDoctorById(String doctorId) async {
    final trimmedId = doctorId.trim();
    if (trimmedId.isEmpty) return null;

    final doc = await _firestore.collection('doctors').doc(trimmedId).get();
    if (!doc.exists) return null;
    return DoctorModel.fromFirestore(doc.data() ?? {}, doc.id);
  }

  @override
  Stream<Doctor?> watchDoctorById(String doctorId) {
    final trimmedId = doctorId.trim();
    if (trimmedId.isEmpty) {
      return Stream<Doctor?>.value(null);
    }

    return _firestore.collection('doctors').doc(trimmedId).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) return null;
        return DoctorModel.fromFirestore(snapshot.data() ?? {}, snapshot.id);
      },
    );
  }

  @override
  Future<void> submitReview({
    required String doctorId,
    required String userId,
    required String userName,
    required String userPhoto,
    required double rating,
    required String comment,
  }) async {
    final trimmedDoctorId = doctorId.trim();
    if (trimmedDoctorId.isEmpty) {
      throw ArgumentError('doctorId must be a non-empty Firestore document id');
    }

    await _firestore.runTransaction((transaction) async {
      final doctorRef = _firestore.collection('doctors').doc(trimmedDoctorId);
      final doctorSnap = await transaction.get(doctorRef);
      final doctorData = doctorSnap.data() ?? {};

      final currentCount = (doctorData['reviewsCount'] as num?)?.toInt() ?? 0;
      final currentRating = (doctorData['rating'] as num?)?.toDouble() ?? 0;
      final reviewsCount = currentCount + 1;
      final totalRating = (currentRating * currentCount) + rating;
      final averageRating =
          double.parse((totalRating / reviewsCount).toStringAsFixed(1));

      final reviewRef = doctorRef.collection('reviews').doc();
      transaction.set(reviewRef, {
        'userId': userId,
        'userName': userName,
        'userPhoto': userPhoto,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(doctorRef, {
        'rating': averageRating,
        'reviewsCount': reviewsCount,
      });
    });
  }

  @override
  Stream<List<ReviewModel>> getDoctorReviews(String doctorId) {
    final trimmedId = doctorId.trim();
    if (trimmedId.isEmpty) {
      return Stream<List<ReviewModel>>.value(const []);
    }

    return _firestore
        .collection('doctors')
        .doc(trimmedId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ReviewModel.fromFirestore)
              .toList(growable: false),
        );
  }

  @override
  Future<List<Doctor>> getTopDoctors({
    String? specialty,
    int limit = 30,
  }) async {
    final trimmedSpecialty = specialty?.trim();

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('doctors')
          .orderBy('rating', descending: true);

      if (trimmedSpecialty != null && trimmedSpecialty.isNotEmpty) {
        query = _firestore
            .collection('doctors')
            .where('specialty', isEqualTo: trimmedSpecialty)
            .orderBy('rating', descending: true);
      }

      final snapshot = await query.limit(limit).get();
      return _mapDoctorDocs(snapshot.docs);
    } on FirebaseException {
      final snapshot = await _firestore.collection('doctors').get();
      var doctors = _mapDoctorDocs(snapshot.docs);
      if (trimmedSpecialty != null && trimmedSpecialty.isNotEmpty) {
        doctors = doctors
            .where((doctor) => doctor.specialty == trimmedSpecialty)
            .toList();
      }
      doctors.sort((a, b) => b.rating.compareTo(a.rating));
      if (doctors.length > limit) {
        doctors = doctors.sublist(0, limit);
      }
      return doctors;
    }
  }

  @override
  Future<List<Doctor>> getAllDoctors() async {
    try {
      final snapshot = await _firestore
          .collection('doctors')
          .orderBy('rating', descending: true)
          .get();
      return _mapDoctorDocs(snapshot.docs);
    } on FirebaseException {
      final snapshot = await _firestore.collection('doctors').get();
      final doctors = _mapDoctorDocs(snapshot.docs)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      return doctors;
    }
  }

  @override
  Future<List<Doctor>> getHospitalSpecialists(String hospitalId) async {
    final trimmedId = hospitalId.trim();
    if (trimmedId.isEmpty) return const [];

    final doc = await _firestore.collection('hospitals').doc(trimmedId).get();
    if (!doc.exists) return const [];

    final ids = _parseIdList(doc.data()?['specialistIds']);
    return _fetchDoctorsByIds(ids, markFavorite: false);
  }

  @override
  Future<List<Doctor>> getFavoriteDoctors() async {
    final ids = await getFavoriteDoctorIds();
    return _fetchDoctorsByIds(ids.toList(), markFavorite: true);
  }

  @override
  Future<List<Hospital>> getFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  }) async {
    final ids = await getFavoriteHospitalIds();
    return _fetchHospitalsByIds(
      ids.toList(),
      currentLat: currentLat,
      currentLng: currentLng,
      markFavorite: true,
    );
  }

  @override
  Future<Set<String>> getFavoriteDoctorIds() async {
    final snapshot = await _userDoc.get();
    return _parseIdList(snapshot.data()?[_favoriteDoctorIdsField]).toSet();
  }

  @override
  Future<Set<String>> getFavoriteHospitalIds() async {
    final snapshot = await _userDoc.get();
    return _parseIdList(snapshot.data()?[_favoriteHospitalIdsField]).toSet();
  }

  @override
  Future<void> setDoctorFavorite({
    required String doctorId,
    required bool isFavorite,
  }) async {
    final trimmedId = doctorId.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('doctorId must be a non-empty Firestore document id');
    }

    await _userDoc.set(
      {
        _favoriteDoctorIdsField: isFavorite
            ? FieldValue.arrayUnion([trimmedId])
            : FieldValue.arrayRemove([trimmedId]),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Stream<List<Doctor>> watchFavoriteDoctors() {
    return _userDoc.snapshots().asyncMap((snapshot) async {
      final ids = _parseIdList(snapshot.data()?[_favoriteDoctorIdsField]);
      return _fetchDoctorsByIds(ids, markFavorite: true);
    });
  }

  @override
  Stream<bool> watchDoctorFavorite(String doctorId) {
    final trimmedId = doctorId.trim();
    if (trimmedId.isEmpty) {
      return Stream<bool>.value(false);
    }

    return _userDoc.snapshots().map((snapshot) {
      final ids = _parseIdList(snapshot.data()?[_favoriteDoctorIdsField]);
      return ids.contains(trimmedId);
    });
  }

  @override
  Stream<List<Hospital>> watchFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  }) {
    return _userDoc.snapshots().asyncMap((snapshot) async {
      final ids = _parseIdList(snapshot.data()?[_favoriteHospitalIdsField]);
      return _fetchHospitalsByIds(
        ids,
        currentLat: currentLat,
        currentLng: currentLng,
        markFavorite: true,
      );
    });
  }

  @override
  Future<void> setHospitalFavorite({
    required String hospitalId,
    required bool isFavorite,
  }) async {
    final trimmedId = hospitalId.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError(
        'hospitalId must be a non-empty Firestore document id',
      );
    }

    await _userDoc.set(
      {
        _favoriteHospitalIdsField: isFavorite
            ? FieldValue.arrayUnion([trimmedId])
            : FieldValue.arrayRemove([trimmedId]),
      },
      SetOptions(merge: true),
    );
  }

  List<String> _parseIdList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((item) => item.toString().trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<Doctor>> _fetchDoctorsByIds(
    List<String> ids, {
    required bool markFavorite,
  }) async {
    if (ids.isEmpty) return const [];

    final uniqueIds = ids.toSet().toList();
    final byId = <String, Doctor>{};

    for (var i = 0; i < uniqueIds.length; i += 30) {
      final chunk = uniqueIds.sublist(i, min(i + 30, uniqueIds.length));
      final snapshot = await _firestore
          .collection('doctors')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        final doctor = DoctorModel.fromFirestore(doc.data(), doc.id);
        byId[doc.id] = markFavorite ? doctor.copyWith(isFavorite: true) : doctor;
      }
    }

    final ordered = <Doctor>[];
    for (final id in ids) {
      final doctor = byId[id];
      if (doctor != null) {
        ordered.add(doctor);
      }
    }
    return ordered;
  }

  Future<List<Hospital>> _fetchHospitalsByIds(
    List<String> ids, {
    required double currentLat,
    required double currentLng,
    required bool markFavorite,
  }) async {
    if (ids.isEmpty) return const [];

    final uniqueIds = ids.toSet().toList();
    final byId = <String, Hospital>{};

    for (var i = 0; i < uniqueIds.length; i += 30) {
      final chunk = uniqueIds.sublist(i, min(i + 30, uniqueIds.length));
      final snapshot = await _firestore
          .collection('hospitals')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        final hospital = Hospital.fromFirestore(
          doc.data(),
          doc.id,
          currentLat: currentLat,
          currentLng: currentLng,
        );
        byId[doc.id] =
            markFavorite ? hospital.copyWith(isFavorite: true) : hospital;
      }
    }

    final ordered = <Hospital>[];
    for (final id in ids) {
      final hospital = byId[id];
      if (hospital != null) {
        ordered.add(hospital);
      }
    }
    return ordered;
  }

  List<Doctor> _mapDoctorDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map((doc) => DoctorModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
