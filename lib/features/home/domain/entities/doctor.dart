class Doctor {
  const Doctor({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
  });

  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final String imageUrl;
}
