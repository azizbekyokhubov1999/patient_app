import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/firestore_parsers.dart';
import '../../../home/domain/entities/hospital.dart';
import '../../../home/domain/entities/hospital_contact_person.dart';

/// Matches [ExploreState.kDefaultUserLat] / [ExploreState.kDefaultUserLng].
const double _kExploreDefaultUserLat = 40.7128;
const double _kExploreDefaultUserLng = -74.006;

/*
const String _kExploreMapPlaceholder =
    'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1200&q=80';

final List<Doctor> _kBrightCareSpecialists = [
  Doctor(
    name: 'Dr. Robert Fox',
    specialty: 'Dentist',
    rating: 5.0,
    reviewsCount: 12,
    imageUrl:
        'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=800&q=80',
    about:
        'Experienced dentist focusing on minimally invasive treatment and preventive care.',
    patientsCount: 890,
    experienceYears: 4,
    workingHours: const [
      WorkingHoursEntry('Monday - Friday', '09:00 am - 06:00 pm'),
    ],
    address: '2464 Royal Ln. Mesa, New Jersey 45463',
    latitude: 40.7153,
    longitude: -74.0024,
    mapImageUrl: _kExploreMapPlaceholder,
    patientReviews: const <DoctorReview>[],
  ),
  Doctor(
    name: 'Dr. Sophia Rossi',
    specialty: 'Otology Specialist',
    rating: 4.9,
    reviewsCount: 53,
    imageUrl:
        'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=800&q=80',
    about:
        'Specialist in ear disorders with extensive surgical and non-surgical care experience.',
    patientsCount: 1200,
    experienceYears: 8,
    workingHours: const [
      WorkingHoursEntry('Monday - Friday', '10:00 am - 06:00 pm'),
      WorkingHoursEntry('Saturday', '10:00 am - 02:00 pm'),
    ],
    address: '2464 Royal Ln. Mesa, New Jersey 45463',
    latitude: 40.7153,
    longitude: -74.0024,
    mapImageUrl: _kExploreMapPlaceholder,
    patientReviews: const <DoctorReview>[],
  ),
];

/// Mock explore data (NYC area) — kept for reference.
Future<List<Hospital>> _mockNearbyHospitals() async {
  return [
    Hospital(
      id: 'h1',
      name: 'BrightCare Medical',
      rating: 4.8,
      tags: 'Dentist, Ophthalmologist, Otology',
      address: '2464 Royal Ln. Mesa, New Jersey 45463',
      distance: '3.5 Miles',
      eta: '15 Min',
      imageUrl:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      treatments: ['Dental Treatments', 'Eye Treatments', 'Ear Treatments'],
      specialists: _kBrightCareSpecialists,
      timings: {
        'Monday': '00:00 - 00:00',
        'Tuesday': '00:00 - 00:00',
        'Wednesday': '00:00 - 00:00',
        'Thursday': '00:00 - 00:00',
        'Friday': '00:00 - 00:00',
        'Saturday': '00:00 - 00:00',
        'Sunday': '00:00 - 00:00',
      },
      contactPerson: HospitalContactPerson(
        name: 'Amelia Clarke',
        role: 'Receptionist',
        avatarUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
      ),
      images: [
        'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
      ],
      galleryImages: [
        'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
      ],
      reviews: [
        HospitalReview(
          userName: 'Leslie Alexander',
          userAvatar:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
          rating: 5.0,
          comment:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
          createdAt: '1 months ago',
          isVerified: true,
        ),
      ],
      latitude: 40.7153,
      longitude: -74.0024,
    ),
    // ... additional mock hospitals h2–h4 omitted for brevity in comment block
  ];
}
*/

abstract class ExploreRemoteDataSource {
  Future<List<Hospital>> fetchNearbyHospitals();
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  ExploreRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<Hospital>> fetchNearbyHospitals() async {
    final snapshot = await _firestore.collection('hospitals').get();
    return snapshot.docs.map(_mapHospitalDocument).toList(growable: false);
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
      currentLat: _kExploreDefaultUserLat,
      currentLng: _kExploreDefaultUserLng,
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
