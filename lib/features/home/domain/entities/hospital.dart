class Hospital {
  const Hospital({
    required this.name,
    required this.rating,
    required this.tags,
    required this.address,
    required this.distance,
    required this.eta,
    required this.imageUrl,
  });

  final String name;
  final double rating;
  final String tags;
  final String address;
  final String distance;
  final String eta;
  final String imageUrl;
}
