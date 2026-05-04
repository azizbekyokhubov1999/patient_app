/// Nearby hospital shown on the Explore map and bottom carousel.
class HospitalExploreModel {
  const HospitalExploreModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.specialties,
    required this.address,
    required this.distanceMilesLabel,
    required this.travelTime,
    required this.distanceDetail,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
  });

  final String id;
  final String name;
  final double rating;
  final String specialties;
  final String address;

  /// Short label under the map pin (e.g. "8.8 mi").
  final String distanceMilesLabel;

  /// e.g. "15 Min".
  final String travelTime;

  /// e.g. "3.5 Miles" for the card row.
  final String distanceDetail;
  final double latitude;
  final double longitude;
  final String? imageUrl;

  HospitalExploreModel copyWith({
    String? id,
    String? name,
    double? rating,
    String? specialties,
    String? address,
    String? distanceMilesLabel,
    String? travelTime,
    String? distanceDetail,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) {
    return HospitalExploreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      specialties: specialties ?? this.specialties,
      address: address ?? this.address,
      distanceMilesLabel: distanceMilesLabel ?? this.distanceMilesLabel,
      travelTime: travelTime ?? this.travelTime,
      distanceDetail: distanceDetail ?? this.distanceDetail,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
