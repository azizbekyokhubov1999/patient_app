import 'hospital_contact_person.dart';
import 'doctor.dart';
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
}
