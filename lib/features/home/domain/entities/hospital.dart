import 'dart:math' show atan2, cos, pi, sin, sqrt;

import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Canonical distance used for sorting and filters (derived if zero).
  final double distanceInMiles;

  /// Travel time estimate in minutes for cards (derived if zero via [eta]).
  final int durationInMinutes;

  /// User favorite flag from auth subcollection when loaded remotely.
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
    final rating = (data['rating'] as num?)?.toDouble() ?? 0;
    final name = data['name'] as String? ?? 'Hospital';
    final specialtiesRaw = data['specialties'];
    final specialties = specialtiesRaw is List
        ? specialtiesRaw.whereType<String>().toList()
        : const <String>[];

    final tags = specialties.isNotEmpty
        ? specialties.join(', ')
        : (data['tags'] as String? ?? '');

    final address = data['address'] as String? ?? '';
    final description = data['description'] as String? ?? '';

    List<String>? treatmentsParsed;
    final treatmentsRaw = data['treatments'];
    if (treatmentsRaw is List) {
      treatmentsParsed = treatmentsRaw.whereType<String>().toList();
    }

    final timingsRaw = data['timings'];
    final timingsParsed = timingsRaw is Map
        ? Map<String, String>.from(
            timingsRaw.map(
              (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
            ),
          )
        : const <String, String>{};

    final contactParsed = HospitalContactPerson(
      name: data['contactName'] as String? ?? '',
      role: data['contactRole'] as String? ?? '',
      avatarUrl: data['contactAvatarUrl'] as String? ?? '',
    );

    List<String>? imagesParsed;
    final imagesRaw = data['images'];
    if (imagesRaw is List) {
      imagesParsed = imagesRaw.whereType<String>().toList();
    }

    List<String>? galleryParsed;
    final galleryRaw = data['galleryImages'];
    if (galleryRaw is List) {
      galleryParsed = galleryRaw.whereType<String>().toList();
    }

    final reviewsRaw = data['reviews'];
    final reviewsParsed = reviewsRaw is List
        ? reviewsRaw
            .whereType<Map>()
            .map(
              (m) => HospitalReview(
                userName: m['userName'] as String? ?? '',
                userAvatar: m['userAvatar'] as String? ?? '',
                rating: (m['rating'] as num?)?.toDouble() ?? 0,
                comment: m['comment'] as String? ?? '',
                createdAt: m['createdAt'] as String? ?? '',
                isVerified: m['isVerified'] as bool? ?? false,
                reviewImages:
                    (m['reviewImages'] as List?)?.whereType<String>().toList() ??
                        const [],
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
        final sid = mm['id'] as String? ?? 'spec_$i';
        out.add(Doctor.fromFirestore(mm, sid));
      }
      specialistsParsed = out;
    }

    final hospLat = (data['latitude'] as num?)?.toDouble() ?? 0;
    final hospLng = (data['longitude'] as num?)?.toDouble() ?? 0;

    var miles =
        (data['distanceInMiles'] as num?)?.toDouble();
    miles ??=
        hospLat.abs() > 1e-6 || hospLng.abs() > 1e-6
            ? _haversineMiles(currentLat, currentLng, hospLat, hospLng)
            : null;

    var durationMinutes = (data['durationInMinutes'] as num?)?.toInt() ?? 0;
    final etaStored = data['eta'] as String? ?? '';

    double milesNonNull = miles ?? 0;
    if (milesNonNull <= 0) {
      final distStr = data['distance'] as String? ?? '';
      final mMatch = RegExp(r'([\d.]+)').firstMatch(distStr);
      milesNonNull = double.tryParse(mMatch?.group(1) ?? '') ?? 0;
    }

    if (durationMinutes <= 0 && etaStored.isNotEmpty) {
      durationMinutes = _parseLeadingInt(etaStored);
    } else if (durationMinutes <= 0 && milesNonNull > 0) {
      durationMinutes =
          (((milesNonNull / 25) * 60).round()).clamp(1, 240);
    }

    final imageUrl = data['imageUrl'] as String? ??
        (imagesParsed != null && imagesParsed.isNotEmpty
            ? imagesParsed.first
            : '');
    final mapImageUrl = data['mapImageUrl'] as String?;

    final distanceLabel = milesNonNull > 0
        ? '${milesNonNull.toStringAsFixed(1)} Miles'
        : ((data['distance'] as String?) ?? '');
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
      treatments:
          treatmentsParsed ?? const [],
      specialists: specialistsParsed ?? const [],
      timings: timingsParsed,
      contactPerson: contactParsed,
      images: imagesParsed ?? const [],
      galleryImages: galleryParsed ?? imagesParsed ?? const [],
      reviews: reviewsParsed,
      latitude: hospLat,
      longitude: hospLng,
      mapImageUrl: mapImageUrl,
      distanceInMiles: milesNonNull,
      durationInMinutes: durationMinutes > 0 ? durationMinutes : 0,
      isFavorite: data['isFavorite'] as bool? ?? false,
    );
  }
}
