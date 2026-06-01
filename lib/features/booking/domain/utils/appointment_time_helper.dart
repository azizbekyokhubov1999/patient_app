import 'package:cloud_firestore/cloud_firestore.dart';

/// Time-window state for upcoming appointment action buttons.
enum AppointmentTimeStatus {
  normal,
  getDirection,
  joinSession,
  scanQr,
}

/// Combines Firestore [date] (day only) with [time] (`HH:mm` or `H:mm`).
DateTime getAppointmentDateTime(Timestamp date, String time) {
  final day = date.toDate();
  return _combineDateAndTime(
    DateTime(day.year, day.month, day.day),
    time,
  );
}

/// Same as [getAppointmentDateTime] when the date is already a [DateTime].
DateTime appointmentDateTimeFromDate(DateTime date, String time) {
  return _combineDateAndTime(
    DateTime(date.year, date.month, date.day),
    time,
  );
}

/// Normalizes Firestore / UI package labels to: inperson, messaging, voicecall, videocall.
String normalizePackageType(String packageType) {
  final p = packageType.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
  if (p == 'inperson' || p == 'offline' || p.contains('inperson')) {
    return 'inperson';
  }
  if (p == 'voicecall' || p == 'voice' || p.contains('voice')) {
    return 'voicecall';
  }
  if (p == 'videocall' || p == 'video' || p.contains('video')) {
    return 'videocall';
  }
  if (p == 'messaging' || p.contains('messag')) {
    return 'messaging';
  }
  return p;
}

AppointmentTimeStatus getTimeStatus(
  DateTime appointmentDateTime,
  String packageType,
) {
  final difference = appointmentDateTime.difference(DateTime.now());
  if (difference.isNegative) {
    return AppointmentTimeStatus.normal;
  }

  final kind = normalizePackageType(packageType);
  final minutesUntil = difference.inMinutes;

  if (kind == 'inperson') {
    if (minutesUntil <= 5) {
      return AppointmentTimeStatus.scanQr;
    }
    if (minutesUntil <= 60) {
      return AppointmentTimeStatus.getDirection;
    }
    return AppointmentTimeStatus.normal;
  }

  if (kind == 'messaging' || kind == 'voicecall' || kind == 'videocall') {
    if (minutesUntil <= 5) {
      return AppointmentTimeStatus.joinSession;
    }
    return AppointmentTimeStatus.normal;
  }

  return AppointmentTimeStatus.normal;
}

DateTime _combineDateAndTime(DateTime dateOnly, String time) {
  final trimmed = time.trim();
  if (trimmed.isEmpty) {
    return dateOnly;
  }

  final parts = trimmed.split(':');
  if (parts.length >= 2) {
    final hour = int.tryParse(parts[0].trim()) ?? 0;
    final minute =
        int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return DateTime(dateOnly.year, dateOnly.month, dateOnly.day, hour, minute);
  }

  return dateOnly;
}
