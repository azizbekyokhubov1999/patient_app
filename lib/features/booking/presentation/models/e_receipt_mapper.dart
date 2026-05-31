import '../../domain/entities/package_type.dart';
import 'booking_route_args.dart';
import 'e_receipt_args.dart';
import 'queue_status_args.dart';

/// Builds [EReceiptArgs] from review-summary route data.
EReceiptArgs buildEReceiptArgsFromReviewSummary(
  ReviewSummaryArgs args, {
  double discount = 0,
  String? appointmentId,
  String patientPhone = '',
  String? qrAppointmentId,
}) {
  final subTotal = _packagePrice(args.selectedPackage);
  final total = (subTotal - discount).clamp(0.0, double.infinity);
  final displayId = appointmentId ?? _generateAppointmentId();

  return EReceiptArgs(
    appointmentId: displayId,
    patientName: args.patientInfo.name,
    patientPhone: patientPhone,
    doctorName: args.doctor?.name ?? 'Dr. Jenny William',
    packageType: _packageLabel(args.selectedPackage),
    packageDuration: '30 minutes',
    bookingDate: args.selectedDate,
    bookingTime: args.selectedTime,
    subTotal: subTotal,
    discount: discount,
    totalAmount: total,
    queueStatusAfterScan: qrAppointmentId != null
        ? QueueStatusArgs(appointmentId: qrAppointmentId)
        : null,
  );
}

String _generateAppointmentId() {
  final seed = DateTime.now().millisecondsSinceEpoch % 1000000000;
  return '#DC$seed';
}

double _packagePrice(PackageType package) {
  switch (package) {
    case PackageType.messaging:
      return 20;
    case PackageType.voiceCall:
      return 40;
    case PackageType.videoCall:
      return 60;
    case PackageType.inPerson:
      return 100;
  }
}

String _packageLabel(PackageType package) {
  switch (package) {
    case PackageType.messaging:
      return 'Messaging';
    case PackageType.voiceCall:
      return 'Voice Call';
    case PackageType.videoCall:
      return 'Video Call';
    case PackageType.inPerson:
      return 'In Person';
  }
}
