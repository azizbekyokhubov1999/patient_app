import '../../domain/entities/doctor.dart';
import '../../domain/entities/filter_result.dart';
import '../../domain/entities/hospital.dart';

String _normalizedMedicalTokens(String raw) =>
    raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');

/// Matches doctor specialty or hospital tag/treatment text to a services grid label.
bool textMatchesServiceCategory(String rawText, String categoryName) {
  if (categoryName == 'All') return true;

  final text = _normalizedMedicalTokens(rawText);
  final cat = _normalizedMedicalTokens(categoryName);
  if (text.isEmpty || cat.isEmpty) return false;
  if (text.contains(cat) || cat.contains(text)) return true;

  const minStem = 4;
  if (cat.length >= minStem && text.contains(cat.substring(0, minStem))) {
    return true;
  }
  if (text.length >= minStem && cat.contains(text.substring(0, minStem))) {
    return true;
  }
  return false;
}

double _parseDistanceMiles(Hospital hospital) {
  final fromLabel = hospital.distance.isNotEmpty
      ? (_parseDistanceMilesFromString(hospital.distance))
      : 0.0;
  if (fromLabel > 0) return fromLabel;
  if (hospital.distanceInMiles > 0) return hospital.distanceInMiles;
  return 0;
}

double _parseDistanceMilesFromString(String distance) {
  final match = RegExp(r'([\d.]+)').firstMatch(distance);
  if (match == null) return 0;
  return double.tryParse(match.group(1) ?? '') ?? 0;
}

double _estimatedFeeForDoctor(Doctor doctor) {
  final specialty = doctor.specialty.toLowerCase();
  if (specialty.contains('dent')) return 20;
  if (specialty.contains('cardio')) return 40;
  if (specialty.contains('neuro') || specialty.contains('radio')) return 35;
  if (specialty.contains('rhino') || specialty.contains('otolog')) return 30;
  return 25;
}

bool _matchesSpecialist(Doctor doctor, String specialist) {
  return textMatchesServiceCategory(doctor.specialty, specialist);
}

bool _matchesConsultationType(Doctor doctor, String consultationType) {
  if (consultationType == 'All') return true;
  return true;
}

List<Doctor> filterDoctors(List<Doctor> doctors, FilterResult filter) {
  return doctors.where((doctor) {
    if (!_matchesSpecialist(doctor, filter.specialist)) return false;
    if (!_matchesConsultationType(doctor, filter.consultationType)) return false;
    if (doctor.rating < filter.minRating || doctor.rating > filter.maxRating) {
      return false;
    }
    final fee = _estimatedFeeForDoctor(doctor);
    if (fee < filter.minFee || fee > filter.maxFee) return false;
    return true;
  }).toList();
}

List<Hospital> filterHospitals(List<Hospital> hospitals, FilterResult filter) {
  return hospitals.where((hospital) {
    if (filter.specialist != 'All') {
      final bundle = [
        hospital.tags,
        ...hospital.treatments,
        ...hospital.specialties,
      ].join(' ');
      if (!textMatchesServiceCategory(bundle, filter.specialist)) {
        return false;
      }
    }
    if (hospital.rating < filter.minRating || hospital.rating > filter.maxRating) {
      return false;
    }
    final miles = _parseDistanceMiles(hospital);
    if (miles < filter.minDistance || miles > filter.maxDistance) return false;
    return true;
  }).toList();
}
