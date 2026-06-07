import '../../domain/entities/doctor.dart';
import '../../domain/entities/working_hours_entry.dart';

/// Firestore mapping for the shared [Doctor] entity.
abstract final class DoctorModel {
  static Doctor fromFirestore(Map<String, dynamic> data, String docId) {
    return fromMap(data, id: docId);
  }

  static Doctor fromMap(Map<String, dynamic> data, {String? id}) {
    final docId = (id ?? data['id'] as String?)?.trim() ?? '';

    final rating = (data['rating'] as num?)?.toDouble() ?? 0;
    final reviewsCount = (data['reviewsCount'] as num?)?.toInt() ??
        (data['reviewCount'] as num?)?.toInt() ??
        0;

    final imageUrl = (data['imageUrl'] as String?)?.trim() ??
        (data['image'] as String?)?.trim() ??
        (data['photoUrl'] as String?)?.trim() ??
        '';

    final lat = (data['latitude'] as num?)?.toDouble() ?? 0;
    final lng = (data['longitude'] as num?)?.toDouble() ?? 0;

    final workingHours = _parseWorkingHours(data['workingHours']);

    return Doctor(
      id: docId.isNotEmpty ? docId : null,
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? (data['name'] as String).trim()
          : 'Doctor',
      specialty: (data['specialty'] as String?)?.trim() ?? '',
      rating: rating,
      reviewsCount: reviewsCount,
      imageUrl: imageUrl,
      about: (data['about'] as String?)?.trim() ?? '',
      patientsCount: (data['patientsCount'] as num?)?.toInt() ?? 0,
      experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 0,
      workingHours: workingHours,
      address: (data['address'] as String?)?.trim() ?? '',
      phone: (data['phone'] as String?)?.trim() ?? '',
      latitude: lat,
      longitude: lng,
      patientReviews: const [],
      mapImageUrl: (data['mapImageUrl'] as String?)?.trim(),
      isFavorite: false,
    );
  }

  static List<WorkingHoursEntry> _parseWorkingHours(dynamic raw) {
    if (raw == null) return const [];

    if (raw is String) {
      final text = raw.trim();
      if (text.isEmpty) return const [];
      if (text.contains('|')) {
        return text
            .split('|')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .map(_entryFromHoursText)
            .toList();
      }
      return [_entryFromHoursText(text)];
    }

    if (raw is List) {
      final entries = <WorkingHoursEntry>[];
      for (final item in raw) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final days = (map['days'] as String?)?.trim() ??
              (map['daysLabel'] as String?)?.trim() ??
              (map['label'] as String?)?.trim() ??
              '';
          final hours = (map['hours'] as String?)?.trim() ??
              (map['hoursLabel'] as String?)?.trim() ??
              (map['time'] as String?)?.trim() ??
              '';
          if (days.isNotEmpty || hours.isNotEmpty) {
            entries.add(WorkingHoursEntry(days, hours));
          }
        } else if (item is String && item.trim().isNotEmpty) {
          entries.add(_entryFromHoursText(item.trim()));
        }
      }
      return entries;
    }

    return const [];
  }

  static WorkingHoursEntry _entryFromHoursText(String text) {
    final colon = text.indexOf(':');
    if (colon > 0 && colon < text.length - 1) {
      return WorkingHoursEntry(
        text.substring(0, colon).trim(),
        text.substring(colon + 1).trim(),
      );
    }
    return WorkingHoursEntry('Schedule', text);
  }
}
