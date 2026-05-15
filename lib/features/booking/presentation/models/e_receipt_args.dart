/// Route arguments for [EReceiptPage].
class EReceiptArgs {
  const EReceiptArgs({
    required this.appointmentId,
    required this.patientName,
    required this.patientPhone,
    required this.doctorName,
    required this.packageType,
    required this.packageDuration,
    required this.bookingDate,
    required this.bookingTime,
    required this.subTotal,
    required this.discount,
    required this.totalAmount,
  });

  final String appointmentId;
  final String patientName;
  final String patientPhone;
  final String doctorName;
  final String packageType;
  final String packageDuration;
  final DateTime bookingDate;
  final String bookingTime;
  final double subTotal;
  final double discount;
  final double totalAmount;

  EReceiptArgs copyWith({
    String? appointmentId,
    String? patientName,
    String? patientPhone,
    String? doctorName,
    String? packageType,
    String? packageDuration,
    DateTime? bookingDate,
    String? bookingTime,
    double? subTotal,
    double? discount,
    double? totalAmount,
  }) {
    return EReceiptArgs(
      appointmentId: appointmentId ?? this.appointmentId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      doctorName: doctorName ?? this.doctorName,
      packageType: packageType ?? this.packageType,
      packageDuration: packageDuration ?? this.packageDuration,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      subTotal: subTotal ?? this.subTotal,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
