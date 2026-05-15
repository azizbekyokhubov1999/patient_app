import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/hospital.dart';
import '../../domain/entities/package_type.dart';
import '../../domain/entities/payment_method_type.dart';
import '../../domain/entities/patient_info.dart';
import '../../domain/entities/card_model.dart';
import 'e_receipt_args.dart';

class BookingRouteArgs {
  const BookingRouteArgs({
    this.doctor,
    this.doctorId,
    this.hospital,
    this.selectedSpecialist,
  });

  final Doctor? doctor;
  final String? doctorId;
  final Hospital? hospital;
  final Doctor? selectedSpecialist;
}

class SelectPackageArgs {
  const SelectPackageArgs({
    required this.selectedDate,
    required this.selectedTime,
    this.selectedPackage,
    this.doctor,
    this.doctorId,
    this.hospital,
  });

  final DateTime selectedDate;
  final String selectedTime;
  final PackageType? selectedPackage;
  final Doctor? doctor;
  final String? doctorId;
  final Hospital? hospital;
}

class PatientDetailsArgs {
  const PatientDetailsArgs({
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedPackage,
    this.doctor,
    this.doctorId,
    this.hospital,
  });

  final DateTime selectedDate;
  final String selectedTime;
  final PackageType selectedPackage;
  final Doctor? doctor;
  final String? doctorId;
  final Hospital? hospital;
}

class PaymentMethodArgs {
  const PaymentMethodArgs({
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedPackage,
    required this.patientInfo,
    this.selectedPaymentMethod,
    this.walletBalance,
    this.savedCards = const [],
    this.selectedCardId,
    this.doctor,
    this.doctorId,
    this.hospital,
  });

  final DateTime selectedDate;
  final String selectedTime;
  final PackageType selectedPackage;
  final PatientInfo patientInfo;
  final PaymentMethodType? selectedPaymentMethod;
  final double? walletBalance;
  final List<CardModel> savedCards;
  final String? selectedCardId;
  final Doctor? doctor;
  final String? doctorId;
  final Hospital? hospital;
}

class ReviewSummaryArgs {
  const ReviewSummaryArgs({
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedPackage,
    required this.patientInfo,
    required this.selectedPaymentMethod,
    required this.walletBalance,
    this.selectedCardId,
    this.doctor,
    this.doctorId,
    this.hospital,
  });

  final DateTime selectedDate;
  final String selectedTime;
  final PackageType selectedPackage;
  final PatientInfo patientInfo;
  final PaymentMethodType selectedPaymentMethod;
  final double walletBalance;
  final String? selectedCardId;
  final Doctor? doctor;
  final String? doctorId;
  final Hospital? hospital;
}

class BookingSuccessArgs {
  const BookingSuccessArgs({
    required this.doctorName,
    required this.receipt,
  });

  final String doctorName;
  final EReceiptArgs receipt;
}
