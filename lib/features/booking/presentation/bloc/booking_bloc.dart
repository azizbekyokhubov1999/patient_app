import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/card_model.dart';
import '../../domain/entities/package_type.dart';
import '../../domain/entities/payment_method_type.dart';
import '../../domain/entities/patient_info.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  static const double walletBalanceDefault = 2400;

  BookingBloc({
    required BookingRepository repository,
    required String doctorId,
    DateTime? initialDate,
    String? initialSelectedTime,
    PackageType? initialSelectedPackage,
    PatientInfo? initialPatientInfo,
    PaymentMethodType? initialSelectedPaymentMethod,
    double? initialWalletBalance,
    List<CardModel> initialSavedCards = const [],
    String? initialSelectedCardId,
  })  : _repository = repository,
        _activeDoctorId = doctorId,
        super(
          BookingInitial(
            selectedDate: _dateOnly(initialDate ?? DateTime.now()),
            selectedTime: initialSelectedTime,
            selectedPackage: initialSelectedPackage,
            patientInfo: initialPatientInfo,
            selectedPaymentMethod: initialSelectedPaymentMethod,
            walletBalance: initialWalletBalance ?? walletBalanceDefault,
            savedCards: initialSavedCards,
            selectedCardId: initialSelectedCardId,
          ),
        ) {
    on<SelectDate>(_onSelectDate);
    on<FetchAvailableSlots>(_onFetchAvailableSlots);
    on<SelectTimeSlot>(_onSelectTimeSlot);
    on<SelectPackageEvent>(_onSelectPackage);
    on<UpdatePatientDetailsEvent>(_onUpdatePatientDetails);
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<SelectSavedCardEvent>(_onSelectSavedCard);
    on<AddNewCardEvent>(_onAddNewCard);
    on<ConfirmBookingEvent>(_onConfirmBooking);
    on<StartBookingEvent>(_onStartBooking);
  }

  final BookingRepository _repository;
  String _activeDoctorId;

  List<TimeSlot> _slotsCache = const [];

  static DateTime _dateOnly(DateTime input) {
    return DateTime(input.year, input.month, input.day);
  }

  Future<void> _onSelectDate(
    SelectDate event,
    Emitter<BookingState> emit,
  ) async {
    await _onFetchAvailableSlots(
      FetchAvailableSlots(_dateOnly(event.date), _activeDoctorId),
      emit,
    );
  }

  Future<void> _onFetchAvailableSlots(
    FetchAvailableSlots event,
    Emitter<BookingState> emit,
  ) async {
    final selectedDate = _dateOnly(event.date);
    _activeDoctorId = event.doctorId;
    emit(
      BookingLoading(
        selectedDate: selectedDate,
        selectedTime: null,
        selectedPackage: state.selectedPackage,
        patientInfo: state.patientInfo,
        selectedPaymentMethod: state.selectedPaymentMethod,
        walletBalance: state.walletBalance,
        savedCards: state.savedCards,
        selectedCardId: state.selectedCardId,
      ),
    );

    try {
      final slots = await _repository.fetchAvailableSlots(
        date: selectedDate,
        doctorId: event.doctorId,
      );

      _slotsCache = slots;
      emit(
        SlotsLoaded(
          slots: slots,
          selectedDate: selectedDate,
          selectedTime: null,
          selectedPackage: state.selectedPackage,
          patientInfo: state.patientInfo,
          selectedPaymentMethod: state.selectedPaymentMethod,
          walletBalance: state.walletBalance,
          savedCards: state.savedCards,
          selectedCardId: state.selectedCardId,
        ),
      );
    } catch (_) {
      emit(
        BookingError(
          message: 'Failed to load available time slots.',
          selectedDate: selectedDate,
          selectedTime: null,
          selectedPackage: state.selectedPackage,
          patientInfo: state.patientInfo,
          selectedPaymentMethod: state.selectedPaymentMethod,
          walletBalance: state.walletBalance,
          savedCards: state.savedCards,
          selectedCardId: state.selectedCardId,
        ),
      );
    }
  }

  void _onSelectTimeSlot(
    SelectTimeSlot event,
    Emitter<BookingState> emit,
  ) {
    if (_slotsCache.isEmpty) {
      return;
    }

    final selected = event.time;
    final updated = _slotsCache.map((slot) {
      if (slot.status == TimeSlotStatus.reserved) {
        return slot;
      }
      if (slot.time == selected) {
        return slot.copyWith(status: TimeSlotStatus.selected);
      }
      return slot.copyWith(status: TimeSlotStatus.available);
    }).toList();

    _slotsCache = updated;
    emit(
      SlotsLoaded(
        slots: updated,
        selectedDate: state.selectedDate,
        selectedTime: selected,
        selectedPackage: state.selectedPackage,
        patientInfo: state.patientInfo,
        selectedPaymentMethod: state.selectedPaymentMethod,
        walletBalance: state.walletBalance,
        savedCards: state.savedCards,
        selectedCardId: state.selectedCardId,
      ),
    );
  }

  void _onSelectPackage(
    SelectPackageEvent event,
    Emitter<BookingState> emit,
  ) {
    final package = event.package;
    final current = state;

    if (current is SlotsLoaded) {
      emit(
        SlotsLoaded(
          slots: current.slots,
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: package,
          patientInfo: current.patientInfo,
          selectedPaymentMethod: current.selectedPaymentMethod,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: current.selectedCardId,
        ),
      );
      return;
    }

    if (current is BookingLoading) {
      emit(
        BookingLoading(
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: package,
          patientInfo: current.patientInfo,
          selectedPaymentMethod: current.selectedPaymentMethod,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: current.selectedCardId,
        ),
      );
      return;
    }

    if (current is BookingError) {
      emit(
        BookingError(
          message: current.message,
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: package,
          patientInfo: current.patientInfo,
          selectedPaymentMethod: current.selectedPaymentMethod,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: current.selectedCardId,
        ),
      );
      return;
    }

    emit(
      BookingInitial(
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: package,
        patientInfo: current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: current.walletBalance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
      ),
    );
  }

  void _onUpdatePatientDetails(
    UpdatePatientDetailsEvent event,
    Emitter<BookingState> emit,
  ) {
    final info = event.info;
    final current = state;

    if (current is SlotsLoaded) {
      emit(
        SlotsLoaded(
          slots: current.slots,
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: current.selectedPackage,
          patientInfo: info,
          selectedPaymentMethod: current.selectedPaymentMethod,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: current.selectedCardId,
        ),
      );
      return;
    }

    if (current is BookingLoading) {
      emit(
        BookingLoading(
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: current.selectedPackage,
          patientInfo: info,
          selectedPaymentMethod: current.selectedPaymentMethod,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: current.selectedCardId,
        ),
      );
      return;
    }

    if (current is BookingError) {
      emit(
        BookingError(
          message: current.message,
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: current.selectedPackage,
          patientInfo: info,
          selectedPaymentMethod: current.selectedPaymentMethod,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: current.selectedCardId,
        ),
      );
      return;
    }

    emit(
      BookingInitial(
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: info,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: current.walletBalance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
      ),
    );
  }

  void _onSelectPaymentMethod(
    SelectPaymentMethodEvent event,
    Emitter<BookingState> emit,
  ) {
    final method = event.method;
    final current = state;

    if (current is SlotsLoaded) {
      emit(
        SlotsLoaded(
          slots: current.slots,
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: current.selectedPackage,
          patientInfo: current.patientInfo,
          selectedPaymentMethod: method,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: current.selectedCardId,
        ),
      );
      return;
    }

    if (current is BookingLoading) {
      emit(
        BookingLoading(
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: current.selectedPackage,
          patientInfo: current.patientInfo,
          selectedPaymentMethod: method,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: current.selectedCardId,
        ),
      );
      return;
    }

    if (current is BookingError) {
      emit(
        BookingError(
          message: current.message,
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: current.selectedPackage,
          patientInfo: current.patientInfo,
          selectedPaymentMethod: method,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: current.selectedCardId,
        ),
      );
      return;
    }

    emit(
      BookingInitial(
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: current.patientInfo,
        selectedPaymentMethod: method,
        walletBalance: current.walletBalance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
      ),
    );
  }

  void _onSelectSavedCard(
    SelectSavedCardEvent event,
    Emitter<BookingState> emit,
  ) {
    final current = state;
    final selectedId = event.cardId;

    if (current is SlotsLoaded) {
      emit(
        SlotsLoaded(
          slots: current.slots,
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: current.selectedPackage,
          patientInfo: current.patientInfo,
          selectedPaymentMethod: PaymentMethodType.creditCard,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: selectedId,
        ),
      );
      return;
    }

    if (current is BookingLoading) {
      emit(
        BookingLoading(
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: current.selectedPackage,
          patientInfo: current.patientInfo,
          selectedPaymentMethod: PaymentMethodType.creditCard,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: selectedId,
        ),
      );
      return;
    }

    if (current is BookingError) {
      emit(
        BookingError(
          message: current.message,
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: current.selectedPackage,
          patientInfo: current.patientInfo,
          selectedPaymentMethod: PaymentMethodType.creditCard,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: selectedId,
        ),
      );
      return;
    }

    emit(
      BookingInitial(
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: current.patientInfo,
        selectedPaymentMethod: PaymentMethodType.creditCard,
        walletBalance: current.walletBalance,
        savedCards: current.savedCards,
        selectedCardId: selectedId,
      ),
    );
  }

  Future<void> _onAddNewCard(
    AddNewCardEvent event,
    Emitter<BookingState> emit,
  ) async {
    final current = state;
    emit(
      CardAddingLoading(
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: current.walletBalance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 220));
    final updatedCards = <CardModel>[...current.savedCards, event.card];

    emit(
      CardAddingSuccess(
        newCard: event.card,
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: current.patientInfo,
        selectedPaymentMethod: PaymentMethodType.creditCard,
        walletBalance: current.walletBalance,
        savedCards: updatedCards,
        selectedCardId: event.card.id,
      ),
    );
  }

  Future<void> _onConfirmBooking(
    ConfirmBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    final current = state;
    emit(
      BookingConfirming(
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: current.walletBalance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 350));

    final hasRequiredData =
        current.selectedTime != null &&
        current.selectedPackage != null &&
        current.patientInfo != null &&
        current.selectedPaymentMethod != null;

    if (!hasRequiredData) {
      emit(
        BookingConfirmFailure(
          message: 'Booking details are incomplete.',
          selectedDate: current.selectedDate,
          selectedTime: current.selectedTime,
          selectedPackage: current.selectedPackage,
          patientInfo: current.patientInfo,
          selectedPaymentMethod: current.selectedPaymentMethod,
          walletBalance: current.walletBalance,
          savedCards: current.savedCards,
          selectedCardId: current.selectedCardId,
        ),
      );
      return;
    }

    emit(
      BookingConfirmed(
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: current.walletBalance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
      ),
    );
  }

  Future<void> _onStartBooking(
    StartBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    _activeDoctorId = event.doctorId;
    _slotsCache = const [];

    emit(
      BookingInitial(
        selectedDate: _dateOnly(event.date),
        selectedTime: null,
        selectedPackage: null,
        patientInfo: null,
        selectedPaymentMethod: null,
        walletBalance: walletBalanceDefault,
        savedCards: const [],
        selectedCardId: null,
      ),
    );

    await _onFetchAvailableSlots(
      FetchAvailableSlots(_dateOnly(event.date), event.doctorId),
      emit,
    );
  }
}
