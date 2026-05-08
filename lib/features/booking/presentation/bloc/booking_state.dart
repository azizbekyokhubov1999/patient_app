import '../../domain/entities/package_type.dart';
import '../../domain/entities/payment_method_type.dart';
import '../../domain/entities/patient_info.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/card_model.dart';

abstract class BookingState {
  const BookingState({
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedPackage,
    required this.patientInfo,
    required this.selectedPaymentMethod,
    required this.walletBalance,
    required this.savedCards,
    required this.selectedCardId,
  });

  final DateTime selectedDate;
  final String? selectedTime;
  final PackageType? selectedPackage;
  final PatientInfo? patientInfo;
  final PaymentMethodType? selectedPaymentMethod;
  final double walletBalance;
  final List<CardModel> savedCards;
  final String? selectedCardId;
}

class BookingInitial extends BookingState {
  const BookingInitial({
    required super.selectedDate,
    super.selectedTime,
    super.selectedPackage,
    super.patientInfo,
    super.selectedPaymentMethod,
    required super.walletBalance,
    super.savedCards = const [],
    super.selectedCardId,
  });
}

class BookingLoading extends BookingState {
  const BookingLoading({
    required super.selectedDate,
    super.selectedTime,
    super.selectedPackage,
    super.patientInfo,
    super.selectedPaymentMethod,
    required super.walletBalance,
    super.savedCards = const [],
    super.selectedCardId,
  });
}

class SlotsLoaded extends BookingState {
  const SlotsLoaded({
    required this.slots,
    required super.selectedDate,
    super.selectedTime,
    super.selectedPackage,
    super.patientInfo,
    super.selectedPaymentMethod,
    required super.walletBalance,
    super.savedCards = const [],
    super.selectedCardId,
  });

  final List<TimeSlot> slots;
}

class BookingError extends BookingState {
  const BookingError({
    required this.message,
    required super.selectedDate,
    super.selectedTime,
    super.selectedPackage,
    super.patientInfo,
    super.selectedPaymentMethod,
    required super.walletBalance,
    super.savedCards = const [],
    super.selectedCardId,
  });

  final String message;
}

class CardAddingLoading extends BookingState {
  const CardAddingLoading({
    required super.selectedDate,
    super.selectedTime,
    super.selectedPackage,
    super.patientInfo,
    super.selectedPaymentMethod,
    required super.walletBalance,
    super.savedCards = const [],
    super.selectedCardId,
  });
}

class CardAddingSuccess extends BookingState {
  const CardAddingSuccess({
    required this.newCard,
    required super.selectedDate,
    super.selectedTime,
    super.selectedPackage,
    super.patientInfo,
    super.selectedPaymentMethod,
    required super.walletBalance,
    super.savedCards = const [],
    super.selectedCardId,
  });

  final CardModel newCard;
}

class CardAddingFailure extends BookingState {
  const CardAddingFailure({
    required this.message,
    required super.selectedDate,
    super.selectedTime,
    super.selectedPackage,
    super.patientInfo,
    super.selectedPaymentMethod,
    required super.walletBalance,
    super.savedCards = const [],
    super.selectedCardId,
  });

  final String message;
}

class BookingConfirming extends BookingState {
  const BookingConfirming({
    required super.selectedDate,
    super.selectedTime,
    super.selectedPackage,
    super.patientInfo,
    super.selectedPaymentMethod,
    required super.walletBalance,
    super.savedCards = const [],
    super.selectedCardId,
  });
}

class BookingConfirmed extends BookingState {
  const BookingConfirmed({
    required super.selectedDate,
    super.selectedTime,
    super.selectedPackage,
    super.patientInfo,
    super.selectedPaymentMethod,
    required super.walletBalance,
    super.savedCards = const [],
    super.selectedCardId,
  });
}

class BookingConfirmFailure extends BookingState {
  const BookingConfirmFailure({
    required this.message,
    required super.selectedDate,
    super.selectedTime,
    super.selectedPackage,
    super.patientInfo,
    super.selectedPaymentMethod,
    required super.walletBalance,
    super.savedCards = const [],
    super.selectedCardId,
  });

  final String message;
}
