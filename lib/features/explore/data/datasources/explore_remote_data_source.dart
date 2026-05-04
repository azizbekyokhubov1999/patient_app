import '../../domain/entities/hospital_explore_model.dart';

/// Mock explore data (NYC area). Replace with API / Firestore later.
abstract class ExploreRemoteDataSource {
  Future<List<HospitalExploreModel>> fetchNearbyHospitals();
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  @override
  Future<List<HospitalExploreModel>> fetchNearbyHospitals() async {
    return const [
      HospitalExploreModel(
        id: 'h1',
        name: 'BrightCare Medical',
        rating: 4.8,
        specialties: 'Dentist, Ophthalmologist, Otology',
        address: '2464 Royal Ln. Mesa, New Jersey 45463',
        distanceMilesLabel: '1.5 mi',
        travelTime: '15 Min',
        distanceDetail: '3.5 Miles',
        latitude: 40.7153,
        longitude: -74.0024,
        imageUrl:
            'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=800&q=80',
      ),
      HospitalExploreModel(
        id: 'h2',
        name: 'HarborView Clinic',
        rating: 4.7,
        specialties: 'Cardiology, General Practice',
        address: '4517 Washington Ave. Manchester, Kentucky 39495',
        distanceMilesLabel: '8.8 mi',
        travelTime: '22 Min',
        distanceDetail: '8.8 Miles',
        latitude: 40.7201,
        longitude: -74.0145,
      ),
      HospitalExploreModel(
        id: 'h3',
        name: 'Metro Health Center',
        rating: 4.9,
        specialties: 'Neurology, Orthopedics',
        address: '3891 Ranchview Dr. Richardson, California 62639',
        distanceMilesLabel: '9.8 mi',
        travelTime: '28 Min',
        distanceDetail: '9.8 Miles',
        latitude: 40.7048,
        longitude: -74.0092,
      ),
      HospitalExploreModel(
        id: 'h4',
        name: 'Eastside Family Care',
        rating: 4.6,
        specialties: 'Pediatrics, Dermatology',
        address: '2972 Westheimer Rd. Santa Ana, Illinois 85486',
        distanceMilesLabel: '7.5 mi',
        travelTime: '19 Min',
        distanceDetail: '7.5 Miles',
        latitude: 40.7182,
        longitude: -73.9945,
      ),
    ];
  }
}
