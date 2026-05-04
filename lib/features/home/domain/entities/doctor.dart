import 'doctor_review.dart';
import 'working_hours_entry.dart';

class Doctor {
  const Doctor({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    required this.about,
    required this.patientsCount,
    required this.experienceYears,
    required this.workingHours,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.patientReviews,
    this.mapImageUrl,
  });

  final String name;
  final String specialty;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final String about;
  final int patientsCount;
  final int experienceYears;
  final List<WorkingHoursEntry> workingHours;
  final String address;
  final double latitude;
  final double longitude;
  final List<DoctorReview> patientReviews;
  final String? mapImageUrl;

  Doctor copyWith({
    String? name,
    String? specialty,
    double? rating,
    int? reviewsCount,
    String? imageUrl,
    String? about,
    int? patientsCount,
    int? experienceYears,
    List<WorkingHoursEntry>? workingHours,
    String? address,
    double? latitude,
    double? longitude,
    List<DoctorReview>? patientReviews,
    String? mapImageUrl,
  }) {
    return Doctor(
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      imageUrl: imageUrl ?? this.imageUrl,
      about: about ?? this.about,
      patientsCount: patientsCount ?? this.patientsCount,
      experienceYears: experienceYears ?? this.experienceYears,
      workingHours: workingHours ?? this.workingHours,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      patientReviews: patientReviews ?? this.patientReviews,
      mapImageUrl: mapImageUrl ?? this.mapImageUrl,
    );
  }
}
