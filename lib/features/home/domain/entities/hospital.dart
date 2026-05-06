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
    );
  }
}
