import '../../../home/domain/entities/hospital.dart';
import '../../../home/domain/entities/hospital_contact_person.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/doctor_review.dart';
import '../../../home/domain/entities/working_hours_entry.dart';
import '../../../home/domain/entities/hospital_review.dart';

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

/// Mock explore data (NYC area). Replace with API / Firestore later.
abstract class ExploreRemoteDataSource {
  Future<List<Hospital>> fetchNearbyHospitals();
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  @override
  Future<List<Hospital>> fetchNearbyHospitals() async {
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
          'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1631248055158-edec7a3c072b?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&w=1200&q=80',
        ],
        galleryImages: [
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1631248055158-edec7a3c072b?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1486825586573-7131f7991bdd?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=1200&q=80',
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
          HospitalReview(
            userName: 'Jenny Wilson',
            userAvatar:
                'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
            rating: 5.0,
            comment:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
            createdAt: '2 months ago',
            isVerified: true,
            reviewImages: [
              'https://images.unsplash.com/photo-1606811971618-4486d14f3f99?auto=format&fit=crop&w=400&q=80',
              'https://plus.unsplash.com/premium_photo-1664475450083-5c9eef17a191?w=500&q=80',
            ],
          ),
        ],
        latitude: 40.7153,
        longitude: -74.0024,
      ),
      Hospital(
        id: 'h2',
        name: 'HarborView Clinic',
        rating: 4.7,
        tags: 'Cardiology, General Practice',
        address: '4517 Washington Ave. Manchester, Kentucky 39495',
        distance: '8.8 Miles',
        eta: '22 Min',
        imageUrl:
            'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=1200&q=80',
        description:
            'Comprehensive care center with modern diagnostics and specialist teams.',
        treatments: [
          'Cardiology Treatments',
          'General Checkups',
          'Lab Diagnostics',
        ],
        specialists: <Doctor>[],
        timings: {
          'Monday': '08:00 - 18:00',
          'Tuesday': '08:00 - 18:00',
          'Wednesday': '08:00 - 18:00',
          'Thursday': '08:00 - 18:00',
          'Friday': '08:00 - 18:00',
          'Saturday': '09:00 - 13:00',
          'Sunday': 'Closed',
        },
        contactPerson: HospitalContactPerson(
          name: 'Sophie Adams',
          role: 'Receptionist',
          avatarUrl:
              'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=300&q=80',
        ),
        images: [
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1486825586573-7131f7991bdd?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=1200&q=80',
        ],
        galleryImages: [
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1486825586573-7131f7991bdd?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1666214280557-f1b5022eb634?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1631815589968-fdb09a223b1e?auto=format&fit=crop&w=1200&q=80',
        ],
        reviews: <HospitalReview>[],
        latitude: 40.7201,
        longitude: -74.0145,
      ),
      Hospital(
        id: 'h3',
        name: 'Metro Health Center',
        rating: 4.9,
        tags: 'Neurology, Orthopedics',
        address: '3891 Ranchview Dr. Richardson, California 62639',
        distance: '9.8 Miles',
        eta: '28 Min',
        imageUrl:
            'https://images.unsplash.com/photo-1666214280557-f1b5022eb634?auto=format&fit=crop&w=1200&q=80',
        description:
            'High-capacity tertiary center focused on emergency and specialty care.',
        treatments: [
          'Neuro Treatments',
          'Orthopedic Procedures',
          'Emergency Care',
        ],
        specialists: <Doctor>[],
        timings: {
          'Monday': '24 Hours',
          'Tuesday': '24 Hours',
          'Wednesday': '24 Hours',
          'Thursday': '24 Hours',
          'Friday': '24 Hours',
          'Saturday': '24 Hours',
          'Sunday': '24 Hours',
        },
        contactPerson: HospitalContactPerson(
          name: 'Noah Bennett',
          role: 'Front Desk',
          avatarUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
        ),
        images: [
          'https://images.unsplash.com/photo-1666214280557-f1b5022eb634?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1631815589968-fdb09a223b1e?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
        ],
        galleryImages: [
          'https://images.unsplash.com/photo-1666214280557-f1b5022eb634?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1631815589968-fdb09a223b1e?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1486825586573-7131f7991bdd?auto=format&fit=crop&w=1200&q=80',
        ],
        reviews: <HospitalReview>[],
        latitude: 40.7048,
        longitude: -74.0092,
      ),
      Hospital(
        id: 'h4',
        name: 'Eastside Family Care',
        rating: 4.6,
        tags: 'Pediatrics, Dermatology',
        address: '2972 Westheimer Rd. Santa Ana, Illinois 85486',
        distance: '7.5 Miles',
        eta: '19 Min',
        imageUrl:
            'https://images.unsplash.com/photo-1538108149393-fbbd81895907?auto=format&fit=crop&w=1200&q=80',
        description:
            'Neighborhood multi-specialty care facility with preventive programs.',
        treatments: [
          'Pediatrics Care',
          'Dermatology Treatments',
          'Family Medicine',
        ],
        specialists: <Doctor>[],
        timings: {
          'Monday': '09:00 - 19:00',
          'Tuesday': '09:00 - 19:00',
          'Wednesday': '09:00 - 19:00',
          'Thursday': '09:00 - 19:00',
          'Friday': '09:00 - 19:00',
          'Saturday': '10:00 - 16:00',
          'Sunday': 'Closed',
        },
        contactPerson: HospitalContactPerson(
          name: 'Lily Thompson',
          role: 'Receptionist',
          avatarUrl:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=300&q=80',
        ),
        images: [
          'https://images.unsplash.com/photo-1538108149393-fbbd81895907?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=1200&q=80',
        ],
        galleryImages: [
          'https://images.unsplash.com/photo-1538108149393-fbbd81895907?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1631248055158-edec7a3c072b?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?auto=format&fit=crop&w=1200&q=80',
        ],
        reviews: <HospitalReview>[],
        latitude: 40.7182,
        longitude: -73.9945,
      ),
    ];
  }
}
