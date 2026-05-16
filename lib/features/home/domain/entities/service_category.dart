class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    required this.iconAsset,
  });

  final String id;
  final String name;
  final String iconAsset;

  ServiceCategory copyWith({
    String? id,
    String? name,
    String? iconAsset,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconAsset: iconAsset ?? this.iconAsset,
    );
  }
}

/// Full catalog of specialties for the Services grid (order matches design).
const List<ServiceCategory> mockServices = [
  ServiceCategory(
    id: 'dentist',
    name: 'Dentist',
    iconAsset: 'assets/images/teeth.svg',
  ),
  ServiceCategory(
    id: 'cardiology',
    name: 'Cardiology',
    iconAsset: 'assets/images/heart.svg',
  ),
  ServiceCategory(
    id: 'orthopaedic',
    name: 'Orthopaedic',
    iconAsset: 'assets/images/orthoped.svg',
  ),
  ServiceCategory(
    id: 'neurology',
    name: 'Neurology',
    iconAsset: 'assets/images/miya.svg',
  ),
  ServiceCategory(
    id: 'otology',
    name: 'Otology',
    iconAsset: 'assets/images/otology.svg',
  ),
  ServiceCategory(
    id: 'gastroenterology',
    name: 'Gastroenterology',
    iconAsset: 'assets/images/gastro.svg',
  ),
  ServiceCategory(
    id: 'rhinology',
    name: 'Rhinology',
    iconAsset: 'assets/images/nose.svg',
  ),
  ServiceCategory(
    id: 'urology',
    name: 'Urology',
    iconAsset: 'assets/images/urology.svg',
  ),
  ServiceCategory(
    id: 'pulmonology',
    name: 'Pulmonology',
    iconAsset: 'assets/images/polmanogy.svg',
  ),
  ServiceCategory(
    id: 'hepatology',
    name: 'Hepatology',
    iconAsset: 'assets/images/hepotology.svg',
  ),
  ServiceCategory(
    id: 'gynecology',
    name: 'Gynecology',
    iconAsset: 'assets/images/gynecology.svg',
  ),
  ServiceCategory(
    id: 'osteology',
    name: 'Osteology',
    iconAsset: 'assets/images/otology.svg',
  ),
  ServiceCategory(
    id: 'ophthalmology',
    name: 'Ophthalmology',
    iconAsset: 'assets/images/ophthal.svg',
  ),
  ServiceCategory(
    id: 'plastic_surgery',
    name: 'Plastic Surgery',
    iconAsset: 'assets/images/plastic_surgery.svg',
  ),
  ServiceCategory(
    id: 'radiology',
    name: 'Radiology',
    iconAsset: 'assets/images/radiology.svg',
  ),
  ServiceCategory(
    id: 'intestinal',
    name: 'Intestinal',
    iconAsset: 'assets/images/intesting.svg',
  ),
  ServiceCategory(
    id: 'pediatric',
    name: 'Pediatric',
    iconAsset: 'assets/images/pediatric.svg',
  ),
  ServiceCategory(
    id: 'naturopathy',
    name: 'Naturopathy',
    iconAsset: 'assets/images/naturopalogy.svg',
  ),
  ServiceCategory(
    id: 'herbal',
    name: 'Herbal',
    iconAsset: 'assets/images/herbal.svg',
  ),
  ServiceCategory(
    id: 'general',
    name: 'General',
    iconAsset: 'assets/images/general.svg',
  ),
];
