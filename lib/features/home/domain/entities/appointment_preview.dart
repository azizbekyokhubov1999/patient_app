import 'package:cloud_firestore/cloud_firestore.dart';

/// Preview row for upcoming appointments list (Firestore `appointments` docs).
///
/// Expected fields on each document:
/// - `patientId` (String), `status` (String),
/// - `doctorName`, `doctorSpecialty`, `doctorRating`,
/// - optional `doctorImageUrl`,
/// - `date` ([Timestamp]),
/// - `startTime`, `endTime` (String, e.g. "09:00").
class AppointmentPreview {
  const AppointmentPreview({
    required this.appointmentId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorRating,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.doctorImageUrl,
  });

  final String appointmentId;
  final String doctorName;
  final String doctorSpecialty;
  final double doctorRating;
  final String? doctorImageUrl;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final String status;

  AppointmentPreview copyWith({
    String? appointmentId,
    String? doctorName,
    String? doctorSpecialty,
    double? doctorRating,
    String? doctorImageUrl,
    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    String? status,
  }) {
    return AppointmentPreview(
      appointmentId: appointmentId ?? this.appointmentId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorRating: doctorRating ?? this.doctorRating,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }

  factory AppointmentPreview.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Appointment document ${doc.id} has no data');
    }

    final dateRaw = data['date'];
    DateTime appointmentDate;
    if (dateRaw is Timestamp) {
      appointmentDate = dateRaw.toDate();
    } else if (dateRaw is DateTime) {
      appointmentDate = dateRaw;
    } else {
      appointmentDate = DateTime.now();
    }

    final ratingRaw = data['doctorRating'];
    double rating = 0;
    if (ratingRaw is num) {
      rating = ratingRaw.toDouble();
    }

    return AppointmentPreview(
      appointmentId: doc.id,
      doctorName: data['doctorName'] as String? ?? '',
      doctorSpecialty: data['doctorSpecialty'] as String? ?? '',
      doctorRating: rating,
      doctorImageUrl: data['doctorImageUrl'] as String?,
      appointmentDate: appointmentDate,
      startTime: data['startTime'] as String? ?? '',
      endTime: data['endTime'] as String? ?? '',
      status: data['status'] as String? ?? 'confirmed',
    );
  }
}
