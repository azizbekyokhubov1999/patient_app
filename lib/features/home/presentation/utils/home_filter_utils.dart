import '../../domain/entities/doctor.dart';
import '../../domain/entities/filter_result.dart';
import '../../domain/entities/hospital.dart';

double _parseDistanceMiles(String distance) {
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
  if (specialist == 'All') return true;
  return doctor.specialty.toLowerCase().contains(specialist.toLowerCase());
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
    if (filter.specialist != 'All' &&
        !hospital.tags.toLowerCase().contains(filter.specialist.toLowerCase())) {
      return false;
    }
    if (hospital.rating < filter.minRating || hospital.rating > filter.maxRating) {
      return false;
    }
    final miles = _parseDistanceMiles(hospital.distance);
    if (miles < filter.minDistance || miles > filter.maxDistance) return false;
    return true;
  }).toList();
}
