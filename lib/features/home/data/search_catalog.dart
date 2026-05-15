import '../domain/entities/doctor.dart';
import '../domain/entities/doctor_review.dart';
import '../domain/entities/hospital.dart';
import '../domain/entities/hospital_contact_person.dart';
import '../domain/entities/hospital_review.dart';
import '../domain/entities/working_hours_entry.dart';
import '../../explore/data/datasources/explore_remote_data_source.dart';

/// In-memory catalog for search (home doctors + explore hospitals).
abstract final class SearchCatalog {
  static const String _mapPlaceholder =
      'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1200&q=80';

  static const String _about =
      'Experienced healthcare professional providing quality patient care.';

  static final List<Doctor> doctors = [
    const Doctor(
      name: 'Dr. Jenny William',
      specialty: 'Dentist',
      rating: 4.9,
      reviewsCount: 5000,
      imageUrl:
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
      about: _about,
      patientsCount: 3500,
      experienceYears: 6,
      workingHours: [
        WorkingHoursEntry('Monday - Friday', '09:00 am - 09:30 pm'),
      ],
      address: '6391 Elgin St. Celina, Delaware 10299',
      latitude: 39.7459,
      longitude: -75.0291,
      mapImageUrl: _mapPlaceholder,
      patientReviews: <DoctorReview>[],
    ),
    const Doctor(
      name: 'Dr. Sophia Rossi',
      specialty: 'Otology Specialist',
      rating: 4.9,
      reviewsCount: 53,
      imageUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=800&q=80',
      about: _about,
      patientsCount: 1200,
      experienceYears: 8,
      workingHours: [
        WorkingHoursEntry('Monday - Friday', '10:00 am - 06:00 pm'),
      ],
      address: '8502 Preston Rd. Inglewood, Maine',
      latitude: 40.7128,
      longitude: -74.0060,
      mapImageUrl: _mapPlaceholder,
      patientReviews: <DoctorReview>[],
    ),
    const Doctor(
      name: 'Dr. Robert Fox',
      specialty: 'Dentist',
      rating: 5.0,
      reviewsCount: 12,
      imageUrl:
          'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=800&q=80',
      about: _about,
      patientsCount: 890,
      experienceYears: 4,
      workingHours: [
        WorkingHoursEntry('Monday - Saturday', '08:00 am - 08:00 pm'),
      ],
      address: '4517 Washington Ave. Manchester, Kentucky 39495',
      latitude: 37.1282,
      longitude: -84.0833,
      mapImageUrl: _mapPlaceholder,
      patientReviews: <DoctorReview>[],
    ),
    const Doctor(
      name: 'Dr. James Chen',
      specialty: 'Radiologist Specialist',
      rating: 4.9,
      reviewsCount: 49,
      imageUrl:
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=800&q=80',
      about: _about,
      patientsCount: 2100,
      experienceYears: 10,
      workingHours: [
        WorkingHoursEntry('Monday - Friday', '08:30 am - 05:30 pm'),
      ],
      address: '2972 Westheimer Rd. Santa Ana, Illinois 85486',
      latitude: 33.7455,
      longitude: -117.8677,
      mapImageUrl: _mapPlaceholder,
      patientReviews: <DoctorReview>[],
    ),
    const Doctor(
      name: 'Dr. Robert Martinez',
      specialty: 'Rhinologist',
      rating: 5.0,
      reviewsCount: 24,
      imageUrl:
          'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=800&q=80',
      about: _about,
      patientsCount: 600,
      experienceYears: 5,
      workingHours: [
        WorkingHoursEntry('Monday - Friday', '09:00 am - 05:00 pm'),
      ],
      address: '2464 Royal Ln. Mesa, New Jersey 45463',
      latitude: 33.4152,
      longitude: -111.8315,
      mapImageUrl: _mapPlaceholder,
      patientReviews: <DoctorReview>[],
    ),
  ];

  static final List<Hospital> homeHospitals = [
    Hospital(
      id: 'hospital-unity-health',
      name: 'Unity Health Hospital',
      rating: 4.8,
      tags: 'Dentist, Ophthalmologist, Otology',
      address: '6391 Elgin St. Celina, Delaware 10299',
      distance: '3.5 Miles',
      eta: '15 Min',
      imageUrl:
          'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=1200&q=80',
      description: _about,
      treatments: ['Dental Treatments', 'Eye Treatments'],
      specialists: const <Doctor>[],
      timings: const {'Monday': '09:00 - 18:00'},
      contactPerson: const HospitalContactPerson(
        name: 'Amelia Clarke',
        role: 'Receptionist',
        avatarUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
      ),
      images: const [],
      galleryImages: const [],
      reviews: const <HospitalReview>[],
      latitude: 39.7459,
      longitude: -75.0291,
      mapImageUrl: _mapPlaceholder,
    ),
    Hospital(
      id: 'hospital-elite-care',
      name: 'Elite Care Center',
      rating: 4.7,
      tags: 'Cardiology, Pediatric',
      address: '8502 Preston Rd. Inglewood, Maine',
      distance: '2.1 Miles',
      eta: '9 Min',
      imageUrl:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
      description: _about,
      treatments: ['Cardiology Treatments'],
      specialists: const <Doctor>[],
      timings: const {'Monday': '08:30 - 17:30'},
      contactPerson: const HospitalContactPerson(
        name: 'Daniel Foster',
        role: 'Front Desk',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      ),
      images: const [],
      galleryImages: const [],
      reviews: const <HospitalReview>[],
      latitude: 43.6572,
      longitude: -70.2568,
      mapImageUrl: _mapPlaceholder,
    ),
    Hospital(
      id: 'hospital-premier-health',
      name: 'Premier Health',
      rating: 4.8,
      tags: 'General Practice, Pediatrics',
      address: '2972 Westheimer Rd. Santa Ana, Illinois 85486',
      distance: '12 Min',
      eta: '12 Min',
      imageUrl:
          'https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&w=1200&q=80',
      description: _about,
      treatments: ['General Checkups'],
      specialists: const <Doctor>[],
      timings: const {'Monday': '08:00 - 20:00'},
      contactPerson: const HospitalContactPerson(
        name: 'Sarah Kim',
        role: 'Receptionist',
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
      ),
      images: const [],
      galleryImages: const [],
      reviews: const <HospitalReview>[],
      latitude: 33.7455,
      longitude: -117.8677,
      mapImageUrl: _mapPlaceholder,
    ),
    Hospital(
      id: 'hospital-elite-medical',
      name: 'Elite Medical',
      rating: 4.9,
      tags: 'Dentist, Dermatology',
      address: '3891 Ranchview Dr. Richardson, California 62639',
      distance: '1.5 Miles',
      eta: '12 Min',
      imageUrl:
          'https://images.unsplash.com/photo-1631248055158-edec7a3c072b?auto=format&fit=crop&w=1200&q=80',
      description: _about,
      treatments: ['Dental Treatments'],
      specialists: const <Doctor>[],
      timings: const {'Monday': '09:00 - 18:00'},
      contactPerson: const HospitalContactPerson(
        name: 'Mark Lewis',
        role: 'Front Desk',
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
      ),
      images: const [],
      galleryImages: const [],
      reviews: const <HospitalReview>[],
      latitude: 32.9483,
      longitude: -96.7299,
      mapImageUrl: _mapPlaceholder,
    ),
  ];

  static Future<List<Hospital>> loadAllHospitals() async {
    final explore = await ExploreRemoteDataSourceImpl().fetchNearbyHospitals();
    final ids = <String>{};
    final merged = <Hospital>[];
    for (final h in [...explore, ...homeHospitals]) {
      if (ids.add(h.id)) merged.add(h);
    }
    return merged;
  }

  static List<Doctor> get defaultRecentDoctors => [
        doctors[4],
        doctors[2],
        doctors[0],
      ];

  static List<String> get defaultRecentKeywords => const [
        'Dental Care',
        'Eye Care',
        'Dentist',
      ];
}
