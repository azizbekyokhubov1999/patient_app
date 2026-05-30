import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import '../models/doctor_model.dart';
import '../models/review_model.dart';

abstract class DoctorRemoteDataSource {
  Future<Doctor?> getDoctorById(String doctorId);

  Stream<Doctor?> watchDoctorById(String doctorId);

  Future<List<Doctor>> getTopDoctors({String? specialty, int limit = 30});

  Future<List<Doctor>> getFavoriteDoctors();

  Stream<List<Doctor>> watchFavoriteDoctors();

  Future<List<Hospital>> getFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  });

  Future<void> setDoctorFavorite({
    required String doctorId,
    required bool isFavorite,
  });

  Stream<bool> watchDoctorFavorite(String doctorId);

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
  DoctorRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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
  Future<List<Doctor>> getFavoriteDoctors() async {
    try {
      final snapshot = await _firestore
          .collection('doctors')
          .where('isFavorite', isEqualTo: true)
          .get();
      return _mapDoctorDocs(snapshot.docs);
    } on FirebaseException {
      final snapshot = await _firestore.collection('doctors').get();
      return _mapDoctorDocs(snapshot.docs)
          .where((doctor) => doctor.isFavorite)
          .toList();
    }
  }

  @override
  Future<List<Hospital>> getFavoriteHospitals({
    double currentLat = 0,
    double currentLng = 0,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('hospitals')
          .where('isFavorite', isEqualTo: true)
          .get();
      return _mapHospitalDocs(snapshot.docs, currentLat, currentLng);
    } on FirebaseException {
      final snapshot = await _firestore.collection('hospitals').get();
      return _mapHospitalDocs(snapshot.docs, currentLat, currentLng)
          .where((hospital) => hospital.isFavorite)
          .toList();
    }
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

    await _firestore.collection('doctors').doc(trimmedId).update({
      'isFavorite': isFavorite,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Doctor>> watchFavoriteDoctors() {
    final controller = StreamController<List<Doctor>>.broadcast();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;
    var useFavoriteQuery = true;

    void listen() {
      subscription?.cancel();
      final query = useFavoriteQuery
          ? _firestore.collection('doctors').where('isFavorite', isEqualTo: true)
          : _firestore.collection('doctors');

      subscription = query.snapshots().listen(
        (snapshot) {
          final doctors = _mapDoctorDocs(snapshot.docs);
          controller.add(
            useFavoriteQuery
                ? doctors
                : doctors.where((doctor) => doctor.isFavorite).toList(),
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          if (useFavoriteQuery) {
            useFavoriteQuery = false;
            listen();
            return;
          }
          controller.addError(error, stackTrace);
        },
      );
    }

    listen();
    controller.onCancel = () => subscription?.cancel();
    return controller.stream;
  }

  @override
  Stream<bool> watchDoctorFavorite(String doctorId) {
    final trimmedId = doctorId.trim();
    if (trimmedId.isEmpty) {
      return Stream<bool>.value(false);
    }

    return _firestore
        .collection('doctors')
        .doc(trimmedId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return false;
      return snapshot.data()?['isFavorite'] as bool? ?? false;
    });
  }

  @override
  Future<void> setHospitalFavorite({
    required String hospitalId,
    required bool isFavorite,
  }) async {
    await _firestore.collection('hospitals').doc(hospitalId).set(
      {
        'isFavorite': isFavorite,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  List<Doctor> _mapDoctorDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map((doc) => DoctorModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  List<Hospital> _mapHospitalDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    double currentLat,
    double currentLng,
  ) {
    return docs
        .map(
          (doc) => Hospital.fromFirestore(
            doc.data(),
            doc.id,
            currentLat: currentLat,
            currentLng: currentLng,
          ),
        )
        .toList();
  }
}
