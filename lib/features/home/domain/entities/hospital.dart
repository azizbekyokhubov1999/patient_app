import 'dart:math' show atan2, cos, pi, sin, sqrt;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/firestore_parsers.dart';
import 'doctor.dart';
import 'hospital_contact_person.dart';
import 'hospital_review.dart';

class Hospital {
  const Hospital({
    required this.id,
    required this.name,
    required this.rating,
    required this.tags,
    required this.address,
    required this.distance,
    required this.eta,
    required this.imageUrl,
    required this.description,
    required this.treatments,
    required this.specialists,
    required this.timings,
    required this.contactPerson,
    required this.images,
    required this.galleryImages,
    required this.reviews,
    required this.latitude,
    required this.longitude,
    this.mapImageUrl,
    this.specialties = const [],
    this.specialistIds = const [],
    this.phone = '',
    this.email = '',
    this.website = '',
    this.workingHours = '',
    this.totalDoctors = 0,
    this.totalPatients = 0,
    this.totalReviews = 0,
    this.distanceInMiles = 0,
    this.durationInMinutes = 0,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final double rating;
  final String tags;
  final String address;
  final String distance;
  final String eta;
  final String imageUrl;
  final String description;
  final List<String> treatments;
  final List<Doctor> specialists;
  final Map<String, String> timings;
  final HospitalContactPerson contactPerson;
  final List<String> images;
  final List<String> galleryImages;
  final List<HospitalReview> reviews;
  final double latitude;
  final double longitude;
  final String? mapImageUrl;

  GeoPoint get geoPoint => GeoPoint(latitude, longitude);

  /// Optional specialty chips (falls back to [tags] in UI when empty).
  final List<String> specialties;

  /// Firestore doctor document ids linked to this hospital.
  final List<String> specialistIds;

  final String phone;
  final String email;
  final String website;
  final String workingHours;
  final int totalDoctors;
  final int totalPatients;
  final int totalReviews;

  /// Canonical distance used for sorting and filters (derived if zero).
  final double distanceInMiles;

  /// Travel time estimate in minutes for cards (derived if zero via [eta]).
  final int durationInMinutes;

  /// UI-only flag — resolved from `users/{uid}.favoriteHospitalIds`.
  final bool isFavorite;

  Hospital copyWith({
    String? id,
    String? name,
    double? rating,
    String? tags,
    String? address,
    String? distance,
    String? eta,
    String? imageUrl,
    String? description,
    List<String>? treatments,
    List<Doctor>? specialists,
    Map<String, String>? timings,
    HospitalContactPerson? contactPerson,
    List<String>? images,
    List<String>? galleryImages,
    List<HospitalReview>? reviews,
    double? latitude,
    double? longitude,
    String? mapImageUrl,
    List<String>? specialties,
    List<String>? specialistIds,
    String? phone,
    String? email,
    String? website,
    String? workingHours,
    int? totalDoctors,
    int? totalPatients,
    int? totalReviews,
    double? distanceInMiles,
    int? durationInMinutes,
    bool? isFavorite,
  }) {
    return Hospital(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      eta: eta ?? this.eta,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      treatments: treatments ?? this.treatments,
      specialists: specialists ?? this.specialists,
      timings: timings ?? this.timings,
      contactPerson: contactPerson ?? this.contactPerson,
      images: images ?? this.images,
      galleryImages: galleryImages ?? this.galleryImages,
      reviews: reviews ?? this.reviews,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapImageUrl: mapImageUrl ?? this.mapImageUrl,
      specialties: specialties ?? this.specialties,
      specialistIds: specialistIds ?? this.specialistIds,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      workingHours: workingHours ?? this.workingHours,
      totalDoctors: totalDoctors ?? this.totalDoctors,
      totalPatients: totalPatients ?? this.totalPatients,
      totalReviews: totalReviews ?? this.totalReviews,
      distanceInMiles: distanceInMiles ?? this.distanceInMiles,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static double _haversineMiles(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusMi = 3958.7613;
    double rad(double deg) => deg * pi / 180;

    final dLat = rad(lat2 - lat1);
    final dLon = rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(rad(lat1)) * cos(rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMi * c;
  }

  static int _parseLeadingInt(String raw) {
    final m = RegExp(r'(\d+)').firstMatch(raw);
    return int.tryParse(m?.group(1) ?? '') ?? 0;
  }

  factory Hospital.fromFirestore(
    Map<String, dynamic> data,
    String docId, {
    required double currentLat,
    required double currentLng,
  }) {
    final rating = FirestoreParsers.asDouble(data['rating']);
    final nameRaw = FirestoreParsers.asString(data['name']);
    final name = nameRaw.isNotEmpty ? nameRaw : 'Hospital';

    final specialties = FirestoreParsers.asStringList(data['specialties'])
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    final tagsRaw = FirestoreParsers.asString(data['tags']);
    final tags = specialties.isNotEmpty ? specialties.join(', ') : tagsRaw;

    final address = FirestoreParsers.asString(data['address']);
    final description = FirestoreParsers.asString(data['description']);
    final treatments = FirestoreParsers.asStringList(data['treatments'])
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    final galleryImages = FirestoreParsers.asStringList(data['galleryImages'])
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    final specialistIds = FirestoreParsers.asStringList(data['specialistIds'])
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    final phone = FirestoreParsers.asString(data['phone']).trim();
    final email = FirestoreParsers.asString(data['email']).trim();
    final website = FirestoreParsers.asString(data['website']).trim();
    final workingHours = FirestoreParsers.asString(data['workingHours']).trim();
    final totalDoctors = FirestoreParsers.asInt(data['totalDoctors']);
    final totalPatients = FirestoreParsers.asInt(data['totalPatients']);
    final reviewsCount = FirestoreParsers.asInt(data['reviewsCount']);
    final totalReviewsField = FirestoreParsers.asInt(data['totalReviews']);
    final totalReviews =
        reviewsCount > 0 ? reviewsCount : totalReviewsField;
    final isFavorite = FirestoreParsers.asBool(data['isFavorite']);

    final timingsRaw = data['timings'];
    final timingsParsed = timingsRaw is Map
        ? Map<String, String>.from(
            timingsRaw.map(
              (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
            ),
          )
        : const <String, String>{};

    final contactParsed = HospitalContactPerson(
      name: FirestoreParsers.asString(data['contactName']),
      role: FirestoreParsers.asString(data['contactRole']),
      avatarUrl: FirestoreParsers.asString(data['contactAvatarUrl']),
    );

    final images = FirestoreParsers.asStringList(data['images'])
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    final reviewsRaw = data['reviews'];
    final reviewsParsed = reviewsRaw is List
        ? reviewsRaw
            .whereType<Map>()
            .map(
              (m) => HospitalReview(
                userName: FirestoreParsers.asString(m['userName']),
                userAvatar: FirestoreParsers.asString(m['userAvatar']),
                rating: FirestoreParsers.asDouble(m['rating']),
                comment: FirestoreParsers.asString(m['comment']),
                createdAt: FirestoreParsers.asString(m['createdAt']),
                isVerified: FirestoreParsers.asBool(m['isVerified']),
                reviewImages: FirestoreParsers.asStringList(m['reviewImages'])
                    .where((item) => item.isNotEmpty)
                    .toList(growable: false),
              ),
            )
            .toList()
        : const <HospitalReview>[];

    List<Doctor>? specialistsParsed;
    final specsRaw = data['specialists'];
    if (specsRaw is List) {
      final out = <Doctor>[];
      for (var i = 0; i < specsRaw.length; i++) {
        final raw = specsRaw[i];
        if (raw is! Map) continue;
        final mm = Map<String, dynamic>.from(raw);
        final sidRaw = FirestoreParsers.asString(mm['id']);
        final sid = sidRaw.isNotEmpty ? sidRaw : 'spec_$i';
        out.add(
          Doctor(
            id: sid,
            name: FirestoreParsers.asString(mm['name'], fallback: 'Doctor'),
            specialty: FirestoreParsers.asString(mm['specialty']),
            rating: FirestoreParsers.asDouble(mm['rating']),
            reviewsCount: FirestoreParsers.asInt(mm['reviewsCount']),
            imageUrl: FirestoreParsers.asString(mm['imageUrl']).trim(),
            about: FirestoreParsers.asString(mm['about']),
            patientsCount: FirestoreParsers.asInt(mm['patientsCount']),
            experienceYears: FirestoreParsers.asInt(mm['experienceYears']),
            workingHours: const [],
            address: FirestoreParsers.asString(mm['address']),
            latitude: FirestoreParsers.asDouble(mm['latitude']),
            longitude: FirestoreParsers.asDouble(mm['longitude']),
            patientReviews: const [],
            isFavorite: false,
          ),
        );
      }
      specialistsParsed = out;
    }

    final hospLat = FirestoreParsers.asDouble(data['latitude']);
    final hospLng = FirestoreParsers.asDouble(data['longitude']);

    var miles = FirestoreParsers.asNum(data['distanceInMiles'])?.toDouble();
    miles ??=
        hospLat.abs() > 1e-6 || hospLng.abs() > 1e-6
            ? _haversineMiles(currentLat, currentLng, hospLat, hospLng)
            : null;

    var durationMinutes = FirestoreParsers.asInt(data['durationInMinutes']);
    final etaStored = FirestoreParsers.asString(data['eta']);

    double milesNonNull = miles ?? 0;
    if (milesNonNull <= 0) {
      final distStr = FirestoreParsers.asString(data['distance']);
      final mMatch = RegExp(r'([\d.]+)').firstMatch(distStr);
      milesNonNull = double.tryParse(mMatch?.group(1) ?? '') ?? 0;
    }

    if (durationMinutes <= 0 && etaStored.isNotEmpty) {
      durationMinutes = _parseLeadingInt(etaStored);
    } else if (durationMinutes <= 0 && milesNonNull > 0) {
      durationMinutes =
          (((milesNonNull / 25) * 60).round()).clamp(1, 240);
    }

    final imageUrlRaw = FirestoreParsers.asString(data['imageUrl']);
    final imageUrl = imageUrlRaw.isNotEmpty
        ? imageUrlRaw
        : (images.isNotEmpty ? images.first : '');

    final mapImageUrlRaw = FirestoreParsers.asString(data['mapImageUrl']);
    final mapImageUrl =
        mapImageUrlRaw.isEmpty ? null : mapImageUrlRaw;

    final distanceStored = FirestoreParsers.asString(data['distance']);
    final distanceLabel = milesNonNull > 0
        ? '${milesNonNull.toStringAsFixed(1)} Miles'
        : distanceStored;
    final etaLabel =
        durationMinutes > 0 ? '$durationMinutes Min' : etaStored;

    return Hospital(
      id: docId,
      name: name,
      rating: rating,
      tags: tags,
      specialties: specialties,
      address: address,
      distance: distanceLabel.isNotEmpty ? distanceLabel : '—',
      eta: etaLabel.isNotEmpty ? etaLabel : '—',
      imageUrl:
          imageUrl.isNotEmpty
              ? imageUrl
              : 'https://picsum.photos/400/200?hospital=$docId',
      description: description,
      treatments: treatments,
      specialists: specialistsParsed ?? const [],
      specialistIds: specialistIds,
      timings: timingsParsed,
      contactPerson: contactParsed,
      images: images,
      galleryImages: galleryImages,
      reviews: reviewsParsed,
      phone: phone,
      email: email,
      website: website,
      workingHours: workingHours,
      totalDoctors: totalDoctors,
      totalPatients: totalPatients,
      totalReviews: totalReviews,
      latitude: hospLat,
      longitude: hospLng,
      mapImageUrl: mapImageUrl,
      distanceInMiles: milesNonNull,
      durationInMinutes: durationMinutes > 0 ? durationMinutes : 0,
      isFavorite: isFavorite,
    );
  }
}
