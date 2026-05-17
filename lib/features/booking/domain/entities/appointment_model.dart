import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Patient appointment document from Firestore `appointments` collection.
class AppointmentModel {
  const AppointmentModel({
    required this.documentId,
    required this.appointmentId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorRating,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.doctorImageUrl,
    this.doctorId,
    this.remindEnabled = true,
    this.patientName,
    this.patientPhone,
    this.packageType = 'Messaging',
    this.packageDuration = '30 minutes',
    this.subTotal = 20,
    this.discount = 0,
    this.totalAmount = 20,
  });

  /// Firestore document id (used for updates).
  final String documentId;

  /// Display / business id (e.g. DC854568).
  final String appointmentId;
  final String? doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final double doctorRating;
  final String? doctorImageUrl;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final String status;
  final bool remindEnabled;
  final String? patientName;
  final String? patientPhone;
  final String packageType;
  final String packageDuration;
  final double subTotal;
  final double discount;
  final double totalAmount;

  String get displayAppointmentId {
    final raw = appointmentId.replaceAll('#', '').toUpperCase();
    return raw.startsWith('DC') ? '#$raw' : '#DC$raw';
  }

  String get bookingDateTimeLabel {
    final date = DateFormat('MMM d, yyyy').format(appointmentDate);
    return '$date - $startTime';
  }

  AppointmentModel copyWith({
    String? documentId,
    String? appointmentId,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    double? doctorRating,
    String? doctorImageUrl,
    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    String? status,
    bool? remindEnabled,
    String? patientName,
    String? patientPhone,
    String? packageType,
    String? packageDuration,
    double? subTotal,
    double? discount,
    double? totalAmount,
  }) {
    return AppointmentModel(
      documentId: documentId ?? this.documentId,
      appointmentId: appointmentId ?? this.appointmentId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorRating: doctorRating ?? this.doctorRating,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      remindEnabled: remindEnabled ?? this.remindEnabled,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      packageType: packageType ?? this.packageType,
      packageDuration: packageDuration ?? this.packageDuration,
      subTotal: subTotal ?? this.subTotal,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Appointment document ${doc.id} has no data');
    }

    final dateRaw = data['date'] ?? data['appointmentDate'];
    DateTime appointmentDate;
    if (dateRaw is Timestamp) {
      appointmentDate = dateRaw.toDate();
    } else if (dateRaw is DateTime) {
      appointmentDate = dateRaw;
    } else {
      appointmentDate = DateTime.now();
    }

    final ratingRaw = data['doctorRating'];
    var rating = 0.0;
    if (ratingRaw is num) {
      rating = ratingRaw.toDouble();
    }

    return AppointmentModel(
      documentId: doc.id,
      appointmentId: data['appointmentId'] as String? ?? doc.id,
      doctorId: data['doctorId'] as String?,
      doctorName: data['doctorName'] as String? ?? 'Doctor',
      doctorSpecialty: data['doctorSpecialty'] as String? ?? '',
      doctorRating: rating,
      doctorImageUrl: data['doctorImageUrl'] as String?,
      appointmentDate: appointmentDate,
      startTime: data['startTime'] as String? ?? '',
      endTime: data['endTime'] as String? ?? '',
      status: data['status'] as String? ?? 'upcoming',
      remindEnabled: data['remindEnabled'] as bool? ?? true,
      patientName: data['patientName'] as String?,
      patientPhone: data['patientPhone'] as String?,
      packageType: data['packageType'] as String? ?? 'Messaging',
      packageDuration: data['packageDuration'] as String? ?? '30 minutes',
      subTotal: (data['subTotal'] as num?)?.toDouble() ?? 20,
      discount: (data['discount'] as num?)?.toDouble() ?? 0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 20,
    );
  }
}
