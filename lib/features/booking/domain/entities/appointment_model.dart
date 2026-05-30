import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Patient appointment document from Firestore `appointments` collection.
class AppointmentModel {
  AppointmentModel({
    required this.documentId,
    required this.appointmentId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorRating,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.patientId,
    this.doctorImageUrl,
    this.doctorId,
    this.remindEnabled = true,
    this.patientName,
    this.patientPhone,
    this.patientGender,
    this.patientAge,
    this.paymentMethod,
    this.packageType = 'Messaging',
    this.packageDuration = '30 minutes',
    this.subTotal = 20,
    this.discount = 0,
    this.totalAmount = 20,
    this.createdAt,
    this.cancelledAt,
    String? type,
    this.sessionStatus = 'pending',
    this.hospitalAddress = '',
    this.hospitalId,
  }) : type = type ?? inferTypeFromPackage(packageType);

  /// Firestore document id (used for updates).
  final String documentId;

  /// Alias for [documentId] matching Firestore document id.
  String get id => documentId;

  /// Display / business id (e.g. DC854568).
  final String appointmentId;
  final String? patientId;
  final String? doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final double doctorRating;
  final String? doctorImageUrl;

  /// Alias for [doctorImageUrl] matching Firestore `doctorImage` field.
  String? get doctorImage => doctorImageUrl;

  final DateTime appointmentDate;

  /// Alias for [appointmentDate] matching Firestore `date` field.
  DateTime get date => appointmentDate;

  final String startTime;

  /// Alias for [startTime] matching Firestore `time` field.
  String get time => startTime;

  final String endTime;
  final String status;
  final bool remindEnabled;
  final String? patientName;
  final String? patientPhone;
  final String? patientGender;
  final String? patientAge;
  final String? paymentMethod;
  final String packageType;
  final String packageDuration;

  /// Matches Firestore `packagePrice`; kept as [subTotal] for existing UI.
  final double subTotal;

  /// Alias for [subTotal] matching Firestore `packagePrice` field.
  double get packagePrice => subTotal;

  final double discount;
  final double totalAmount;
  final DateTime? createdAt;
  final DateTime? cancelledAt;

  /// `video`, `voice`, `messaging`, or `offline`.
  final String type;

  /// `pending`, `started_by_doctor`, or `completed`.
  final String sessionStatus;

  final String hospitalAddress;
  final String? hospitalId;

  /// Combined date + [startTime] for time-based UI triggers.
  DateTime get appointmentTime =>
      parseAppointmentDateTime(appointmentDate, startTime);

  bool get showJoinSession =>
      type != 'offline' &&
      sessionStatus == 'started_by_doctor' &&
      DateTime.now().difference(appointmentTime).inMinutes.abs() <= 5;

  bool get showGetDirection =>
      type == 'offline' &&
      appointmentTime.difference(DateTime.now()).inHours <= 1 &&
      sessionStatus == 'pending';

  bool get showScanQR =>
      type == 'offline' &&
      appointmentTime.difference(DateTime.now()).inMinutes <= 5 &&
      sessionStatus == 'pending';

  bool get isSessionCompleted => sessionStatus == 'completed';

  String get displayAppointmentId {
    final raw = appointmentId.replaceAll('#', '').trim();
    if (raw.isEmpty) return '#--------';
    final slice = raw.length >= 8 ? raw.substring(0, 8) : raw;
    return '#${slice.toUpperCase()}';
  }

  String get bookingDateTimeLabel {
    final date = DateFormat('MMM d, yyyy').format(appointmentDate);
    return '$date - $startTime';
  }

  static String inferTypeFromPackage(String packageType) {
    final p = packageType.toLowerCase();
    if (p.contains('video')) return 'video';
    if (p.contains('voice')) return 'voice';
    if (p.contains('messag')) return 'messaging';
    if (p.contains('offline') || p.contains('in-person') || p.contains('in person')) {
      return 'offline';
    }
    return 'messaging';
  }

  static DateTime parseAppointmentDateTime(DateTime date, String time) {
    final trimmed = time.trim();
    if (trimmed.isEmpty) {
      return DateTime(date.year, date.month, date.day);
    }

    for (final pattern in ['h:mm a', 'hh:mm a', 'H:mm', 'HH:mm']) {
      try {
        final parsed = DateFormat(pattern).parse(trimmed);
        return DateTime(
          date.year,
          date.month,
          date.day,
          parsed.hour,
          parsed.minute,
        );
      } catch (_) {
        continue;
      }
    }

    final parts = trimmed.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    return DateTime(date.year, date.month, date.day);
  }

  AppointmentModel copyWith({
    String? documentId,
    String? appointmentId,
    String? patientId,
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
    String? patientGender,
    String? patientAge,
    String? paymentMethod,
    String? packageType,
    String? packageDuration,
    double? subTotal,
    double? discount,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? cancelledAt,
    String? type,
    String? sessionStatus,
    String? hospitalAddress,
    String? hospitalId,
  }) {
    return AppointmentModel(
      documentId: documentId ?? this.documentId,
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
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
      patientGender: patientGender ?? this.patientGender,
      patientAge: patientAge ?? this.patientAge,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      packageType: packageType ?? this.packageType,
      packageDuration: packageDuration ?? this.packageDuration,
      subTotal: subTotal ?? this.subTotal,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      type: type ?? this.type,
      sessionStatus: sessionStatus ?? this.sessionStatus,
      hospitalAddress: hospitalAddress ?? this.hospitalAddress,
      hospitalId: hospitalId ?? this.hospitalId,
    );
  }

  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return AppointmentModel.fromFirestoreMap(doc.data(), doc.id);
  }

  factory AppointmentModel.fromFirestoreMap(
    Map<String, dynamic>? data,
    String docId,
  ) {
    if (data == null) {
      throw StateError('Appointment document $docId has no data');
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

    DateTime? createdAt;
    final createdRaw = data['createdAt'];
    if (createdRaw is Timestamp) {
      createdAt = createdRaw.toDate();
    } else if (createdRaw is DateTime) {
      createdAt = createdRaw;
    }

    DateTime? cancelledAt;
    final cancelledRaw = data['cancelledAt'];
    if (cancelledRaw is Timestamp) {
      cancelledAt = cancelledRaw.toDate();
    } else if (cancelledRaw is DateTime) {
      cancelledAt = cancelledRaw;
    }

    final ratingRaw = data['doctorRating'];
    var rating = 0.0;
    if (ratingRaw is num) {
      rating = ratingRaw.toDouble();
    }

    final packageType = data['packageType'] as String? ?? 'Messaging';
    final startTime =
        data['time'] as String? ?? data['startTime'] as String? ?? '';
    final endTime = data['endTime'] as String? ?? startTime;
    final packagePrice = (data['packagePrice'] as num?)?.toDouble() ??
        (data['subTotal'] as num?)?.toDouble() ??
        20;

    return AppointmentModel(
      documentId: docId,
      appointmentId: data['appointmentId'] as String? ?? docId,
      patientId: data['patientId'] as String?,
      doctorId: data['doctorId'] as String?,
      doctorName: data['doctorName'] as String? ?? 'Doctor',
      doctorSpecialty: data['doctorSpecialty'] as String? ?? '',
      doctorRating: rating,
      doctorImageUrl: data['doctorImage'] as String? ??
          data['doctorImageUrl'] as String?,
      appointmentDate: appointmentDate,
      startTime: startTime,
      endTime: endTime,
      status: data['status'] as String? ?? 'confirmed',
      remindEnabled: data['remindEnabled'] as bool? ?? true,
      patientName: data['patientName'] as String?,
      patientPhone: data['patientPhone'] as String?,
      patientGender: data['patientGender'] as String?,
      patientAge: data['patientAge']?.toString(),
      paymentMethod: data['paymentMethod'] as String?,
      packageType: packageType,
      packageDuration: data['packageDuration'] as String? ?? '30 minutes',
      subTotal: packagePrice,
      discount: (data['discount'] as num?)?.toDouble() ?? 0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? packagePrice,
      createdAt: createdAt,
      cancelledAt: cancelledAt,
      type: data['type'] as String?,
      sessionStatus: data['sessionStatus'] as String? ?? 'pending',
      hospitalAddress: data['hospitalAddress'] as String? ?? '',
      hospitalId: data['hospitalId'] as String?,
    );
  }
}
