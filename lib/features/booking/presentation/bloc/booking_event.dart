import '../../domain/entities/package_type.dart';
import '../../domain/entities/payment_method_type.dart';
import '../../domain/entities/patient_info.dart';
import '../../domain/entities/card_model.dart';

abstract class BookingEvent {
  const BookingEvent();
}

class FetchAvailableSlots extends BookingEvent {
  const FetchAvailableSlots(this.date, this.doctorId);

  final DateTime date;
  final String doctorId;
}

class SelectDate extends BookingEvent {
  const SelectDate(this.date);

  final DateTime date;
}

class SelectTimeSlot extends BookingEvent {
  const SelectTimeSlot(this.time);

  final String time;
}

class SelectPackageEvent extends BookingEvent {
  const SelectPackageEvent(this.package);

  final PackageType package;
}

class UpdatePatientDetailsEvent extends BookingEvent {
  const UpdatePatientDetailsEvent(this.info);

  final PatientInfo info;
}

class SelectPaymentMethodEvent extends BookingEvent {
  const SelectPaymentMethodEvent(this.method);

  final PaymentMethodType method;
}

class SelectSavedCardEvent extends BookingEvent {
  const SelectSavedCardEvent(this.cardId);

  final String cardId;
}

class AddNewCardEvent extends BookingEvent {
  const AddNewCardEvent(this.card);

  final CardModel card;
}
