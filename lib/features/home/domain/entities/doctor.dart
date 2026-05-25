import 'doctor_review.dart';
import 'working_hours_entry.dart';

class Doctor {
  const Doctor({
    this.id,
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
    this.isFavorite = false,
  });

  /// Firestore document id when loaded remotely.
  final String? id;

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

  /// Persisted on the `doctors/{docId}` document in Firestore.
  final bool isFavorite;

  Doctor copyWith({
    String? id,
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
    bool? isFavorite,
  }) {
    return Doctor(
      id: id ?? this.id,
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
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Doctor.fromFirestore(Map<String, dynamic> json, String docId) {
    final rating = (json['rating'] as num?)?.toDouble() ?? 0;
    final reviewsCount = (json['reviewsCount'] as num?)?.toInt() ??
        (json['reviewCount'] as num?)?.toInt() ??
        0;
    final imageUrl = (json['imageUrl'] as String?)?.trim() ??
        (json['image'] as String?)?.trim() ??
        (json['photoUrl'] as String?)?.trim() ??
        '';
    final lat = (json['latitude'] as num?)?.toDouble() ?? 0;
    final lng = (json['longitude'] as num?)?.toDouble() ?? 0;

    return Doctor(
      id: docId,
      name: json['name'] as String? ?? 'Doctor',
      specialty: json['specialty'] as String? ?? '',
      rating: rating,
      reviewsCount: reviewsCount,
      imageUrl: imageUrl,
      about: json['about'] as String? ?? '',
      patientsCount: (json['patientsCount'] as num?)?.toInt() ?? 0,
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      workingHours: const [
        WorkingHoursEntry('Monday - Friday', '09:00 am - 06:00 pm'),
      ],
      address: json['address'] as String? ?? '',
      latitude: lat,
      longitude: lng,
      patientReviews: const [],
      mapImageUrl: json['mapImageUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
