import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/firestore_parsers.dart';
import '../../domain/entities/appointment_preview.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/hospital_contact_person.dart';
import '../models/doctor_model.dart';
import '../models/review_model.dart';

/// Default map center (same as Explore tab).
const double _kDefaultUserLat = 40.7128;
const double _kDefaultUserLng = -74.006;

abstract class HomeRemoteDataSource {
  Future<List<Doctor>> getTopDoctors();

  /// Full doctor list for home filter catalog.
  Future<List<Doctor>> getAllDoctors();

  /// Home carousel — top hospitals preview (limit 4).
  Future<List<Hospital>> getNearbyHospitals();

  /// Full hospital list for search / filter catalogs.
  Future<List<Hospital>> getAllHospitals();

  /// Home carousel — next confirmed appointments (limit 3).
  Future<List<AppointmentPreview>> getUpcomingAppointments(String uid);

  /// Upcoming appointments "See All" — all confirmed upcoming for patient.
  Future<List<AppointmentPreview>> getAllUpcomingAppointments(String uid);

  /// Full hospital document for detail screens.
  Future<Hospital?> getHospitalById(String id);

  Future<Hospital?> getHospitalByName(String name);

  Future<void> submitHospitalReview({
    required String hospitalId,
    required String userId,
    required String userName,
    required String userPhoto,
    required double rating,
    required String comment,
  });

  Stream<List<ReviewModel>> getHospitalReviews(String hospitalId);

  Stream<Hospital?> watchHospitalById(String id);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<Doctor>> getTopDoctors() async {
    const limit = 4;

    try {
      final snapshot = await _firestore
          .collection('doctors')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();
      return _mapDoctorDocs(snapshot.docs);
    } on FirebaseException {
      final snapshot = await _firestore.collection('doctors').get();
      final doctors = _mapDoctorDocs(snapshot.docs)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      if (doctors.length > limit) {
        return doctors.sublist(0, limit);
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
  Future<List<Hospital>> getNearbyHospitals() async {
    const limit = 4;

    final snapshot = await _firestore.collection('hospitals').limit(limit).get();
    return snapshot.docs.map(_mapHospitalDocument).toList(growable: false);
  }

  @override
  Future<List<AppointmentPreview>> getUpcomingAppointments(String uid) =>
      _fetchUpcomingAppointments(uid, limit: 3);

  @override
  Future<List<AppointmentPreview>> getAllUpcomingAppointments(String uid) =>
      _fetchUpcomingAppointments(uid);

  @override
  Future<List<Hospital>> getAllHospitals() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _firestore
          .collection('hospitals')
          .orderBy('rating', descending: true)
          .get();
    } on FirebaseException {
      snapshot = await _firestore.collection('hospitals').get();
      final docs = snapshot.docs.toList()
        ..sort((a, b) {
          final ra = (a.data()['rating'] as num?)?.toDouble() ?? 0;
          final rb = (b.data()['rating'] as num?)?.toDouble() ?? 0;
          return rb.compareTo(ra);
        });
      return docs.map(_mapHospitalDocument).toList(growable: false);
    }

    return snapshot.docs.map(_mapHospitalDocument).toList(growable: false);
  }

  Future<List<AppointmentPreview>> _fetchUpcomingAppointments(
    String uid, {
    int? limit,
  }) async {
    final trimmedUid = uid.trim();
    if (trimmedUid.isEmpty) return const [];

    Query<Map<String, dynamic>> query = _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: trimmedUid)
        .where('status', isEqualTo: 'confirmed');

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      final ordered = query.orderBy('date', descending: false);
      snapshot = limit != null
          ? await ordered.limit(limit).get()
          : await ordered.get();
    } on FirebaseException {
      snapshot = await query.get();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final items = snapshot.docs
        .map(AppointmentPreview.fromFirestore)
        .where((preview) {
          final day = DateTime(
            preview.appointmentDate.year,
            preview.appointmentDate.month,
            preview.appointmentDate.day,
          );
          return !day.isBefore(today);
        })
        .toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

    if (limit != null && items.length > limit) {
      return items.sublist(0, limit);
    }
    return items;
  }

  @override
  Future<Hospital?> getHospitalById(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return null;

    final doc = await _firestore.collection('hospitals').doc(trimmed).get();
    if (!doc.exists) return null;

    return Hospital.fromFirestore(
      doc.data() ?? const {},
      doc.id,
      currentLat: _kDefaultUserLat,
      currentLng: _kDefaultUserLng,
    );
  }

  @override
  Future<Hospital?> getHospitalByName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final snapshot = await _firestore
        .collection('hospitals')
        .where('name', isEqualTo: trimmed)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return Hospital.fromFirestore(
      doc.data(),
      doc.id,
      currentLat: _kDefaultUserLat,
      currentLng: _kDefaultUserLng,
    );
  }

  @override
  Future<void> submitHospitalReview({
    required String hospitalId,
    required String userId,
    required String userName,
    required String userPhoto,
    required double rating,
    required String comment,
  }) async {
    final trimmedHospitalId = hospitalId.trim();
    if (trimmedHospitalId.isEmpty) {
      throw ArgumentError(
        'hospitalId must be a non-empty Firestore document id',
      );
    }

    final hospitalRef =
        _firestore.collection('hospitals').doc(trimmedHospitalId);
    final reviewRef = hospitalRef.collection('reviews').doc();

    await reviewRef.set({
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.now(),
    });

    final reviewsSnap = await hospitalRef.collection('reviews').get();

    var sum = 0.0;
    final count = reviewsSnap.docs.length;
    for (final doc in reviewsSnap.docs) {
      sum += FirestoreParsers.asDouble(doc.data()['rating']);
    }

    final averageRating = count > 0
        ? double.parse((sum / count).toStringAsFixed(1))
        : 0.0;

    await hospitalRef.update({
      'rating': averageRating,
      'reviewsCount': count,
    });
  }

  @override
  Stream<List<ReviewModel>> getHospitalReviews(String hospitalId) {
    final trimmedId = hospitalId.trim();
    if (trimmedId.isEmpty) {
      return Stream<List<ReviewModel>>.value(const []);
    }

    return _firestore
        .collection('hospitals')
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
  Stream<Hospital?> watchHospitalById(String id) {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      return Stream<Hospital?>.value(null);
    }

    return _firestore.collection('hospitals').doc(trimmedId).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) return null;
        return Hospital.fromFirestore(
          snapshot.data() ?? const {},
          snapshot.id,
          currentLat: _kDefaultUserLat,
          currentLng: _kDefaultUserLng,
        );
      },
    );
  }

  List<Doctor> _mapDoctorDocs(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map((doc) => DoctorModel.fromFirestore(doc.data(), doc.id))
        .toList(growable: false);
  }

  Hospital _mapHospitalDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final imageUrl = FirestoreParsers.asString(data['imageUrl']).trim();
    final storedDistance = FirestoreParsers.asString(data['distance']).trim();
    final storedEta = FirestoreParsers.asString(data['eta']).trim();

    final hospital = Hospital.fromFirestore(
      data,
      doc.id,
      currentLat: _kDefaultUserLat,
      currentLng: _kDefaultUserLng,
    );

    return hospital.copyWith(
      distance: storedDistance.isNotEmpty ? storedDistance : hospital.distance,
      eta: storedEta.isNotEmpty ? storedEta : hospital.eta,
      specialists: const [],
      reviews: const [],
      treatments: const [],
      timings: const {},
      contactPerson: const HospitalContactPerson(
        name: '',
        role: '',
        avatarUrl: '',
      ),
      images: imageUrl.isNotEmpty ? [imageUrl] : const [],
      galleryImages: imageUrl.isNotEmpty ? [imageUrl] : const [],
      mapImageUrl: imageUrl.isNotEmpty ? imageUrl : hospital.mapImageUrl,
    );
  }
}
