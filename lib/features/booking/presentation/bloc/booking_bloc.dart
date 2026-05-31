import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/doctor.dart';
import '../../../payment/data/datasources/wallet_remote_data_source.dart';
import '../../../payment/data/repositories/wallet_repository_impl.dart';
import '../../../payment/domain/repositories/wallet_repository.dart';
import '../../../profile/data/datasources/profile_remote_data_source.dart';
import '../../../profile/data/repositories/profile_repository_impl.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../chat/data/datasources/chat_remote_data_source.dart';
import '../../../chat/data/repositories/chat_repository_impl.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import '../../../notification/data/datasources/notification_remote_data_source.dart';
import '../../../notification/data/repositories/notification_repository_impl.dart';
import '../../../notification/domain/repositories/notification_repository.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/card_model.dart';
import '../../domain/entities/package_type.dart';
import '../../domain/entities/payment_method_type.dart';
import '../../domain/entities/patient_info.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  static const double bookingDiscount = 4;

  BookingBloc({
    required BookingRepository repository,
    required String doctorId,
    Doctor? doctor,
    DateTime? initialDate,
    String? initialSelectedTime,
    PackageType? initialSelectedPackage,
    PatientInfo? initialPatientInfo,
    PaymentMethodType? initialSelectedPaymentMethod,
    double? initialWalletBalance,
    List<CardModel> initialSavedCards = const [],
    String? initialSelectedCardId,
    FirebaseAuth? auth,
    ProfileRepository? profileRepository,
    WalletRepository? walletRepository,
    NotificationRepository? notificationRepository,
    ChatRepository? chatRepository,
  })  : _repository = repository,
        _auth = auth ?? FirebaseAuth.instance,
        _profileRepository = profileRepository ??
            ProfileRepositoryImpl(ProfileRemoteDataSourceImpl(auth: auth)),
        _walletRepository = walletRepository ??
            WalletRepositoryImpl(WalletRemoteDataSourceImpl()),
        _notificationRepository = notificationRepository ??
            NotificationRepositoryImpl(NotificationRemoteDataSourceImpl()),
        _chatRepository = chatRepository ??
            ChatRepositoryImpl(ChatRemoteDataSourceImpl()),
        _activeDoctorId = _resolveDoctorId(doctor, doctorId),
        _doctorName = doctor?.name ?? '',
        _doctorSpecialty = doctor?.specialty ?? '',
        _doctorImage = doctor?.imageUrl ?? '',
        _doctorRating = doctor?.rating ?? 0,
        super(
          BookingInitial(
            selectedDate: _dateOnly(initialDate ?? DateTime.now()),
            selectedTime: initialSelectedTime,
            selectedPackage: initialSelectedPackage,
            patientInfo: initialPatientInfo,
            selectedPaymentMethod: initialSelectedPaymentMethod,
            walletBalance: initialWalletBalance ?? 0,
            savedCards: initialSavedCards,
            selectedCardId: initialSelectedCardId,
          ),
        ) {
    on<SelectDate>(_onSelectDate);
    on<FetchAvailableSlots>(_onFetchAvailableSlots);
    on<SelectTimeSlot>(_onSelectTimeSlot);
    on<SelectPackageEvent>(_onSelectPackage);
    on<UpdatePatientDetailsEvent>(_onUpdatePatientDetails);
    on<SelectPatientTypeEvent>(_onSelectPatientType);
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<SelectSavedCardEvent>(_onSelectSavedCard);
    on<AddNewCardEvent>(_onAddNewCard);
    on<ConfirmBookingEvent>(_onConfirmBooking);
    on<StartBookingEvent>(_onStartBooking);
    on<WalletBalanceUpdatedEvent>(_onWalletBalanceUpdated);

    _startWalletBalanceWatch();
  }

  final BookingRepository _repository;
  final ProfileRepository _profileRepository;
  final WalletRepository _walletRepository;
  final NotificationRepository _notificationRepository;
  final ChatRepository _chatRepository;
  final FirebaseAuth _auth;
  String _activeDoctorId;
  final String _doctorName;
  final String _doctorSpecialty;
  final String _doctorImage;
  final double _doctorRating;

  List<TimeSlot> _slotsCache = const [];
  StreamSubscription<double>? _walletBalanceSub;
  double _cachedWalletBalance = 0;

  static String _resolveDoctorId(Doctor? doctor, String fallbackDoctorId) {
    if (doctor != null) {
      if (doctor.documentId.isNotEmpty) return doctor.documentId;
      final id = doctor.id?.trim();
      if (id != null && id.isNotEmpty) return id;
    }
    return fallbackDoctorId.trim();
  }

  static DateTime _dateOnly(DateTime input) {
    return DateTime(input.year, input.month, input.day);
  }

  void _startWalletBalanceWatch() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    unawaited(_walletBalanceSub?.cancel());
    _walletBalanceSub = _walletRepository.getWalletBalance(uid).listen(
      (balance) {
        _cachedWalletBalance = balance;
        if (!isClosed) {
          add(WalletBalanceUpdatedEvent(balance));
        }
      },
    );
  }

  void _onWalletBalanceUpdated(
    WalletBalanceUpdatedEvent event,
    Emitter<BookingState> emit,
  ) {
    emit(_mapState(state, walletBalance: event.balance));
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
    final today = _dateOnly(DateTime.now());
    final isPastDate = selectedDate.isBefore(today);

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

    if (isPastDate) {
      _slotsCache = const [];
      emit(
        SlotsLoaded(
          slots: const [],
          selectedDate: selectedDate,
          selectedTime: null,
          selectedPackage: state.selectedPackage,
          patientInfo: state.patientInfo,
          selectedPaymentMethod: state.selectedPaymentMethod,
          walletBalance: state.walletBalance,
          savedCards: state.savedCards,
          selectedCardId: state.selectedCardId,
          isDoctorAvailable: true,
          isPastDate: true,
        ),
      );
      return;
    }

    try {
      final slots = await _repository.getDoctorSlots(
        event.doctorId,
        selectedDate,
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
          isDoctorAvailable: slots.isNotEmpty,
          isPastDate: false,
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
    final slotFlags = state is SlotsLoaded ? state as SlotsLoaded : null;
    final updated = _slotsCache.map((slot) {
      if (slot.status == TimeSlotStatus.reserved || !slot.isAvailable) {
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
        isDoctorAvailable: slotFlags?.isDoctorAvailable ?? true,
        isPastDate: slotFlags?.isPastDate ?? false,
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
          isDoctorAvailable: current.isDoctorAvailable,
          isPastDate: current.isPastDate,
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
    emit(_mapState(state, patientInfo: info));
  }

  Future<void> _onSelectPatientType(
    SelectPatientTypeEvent event,
    Emitter<BookingState> emit,
  ) async {
    final current = state;

    if (!event.isForSelf) {
      emit(
        _mapState(
          current,
          clearSelfAutofill: true,
          selfAutofillGeneration: current.selfAutofillGeneration + 1,
        ),
      );
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(
        _mapState(
          current,
          selfAutofillName: '',
          selfAutofillGender: '',
          selfAutofillGeneration: current.selfAutofillGeneration + 1,
        ),
      );
      return;
    }

    try {
      final profile = await _profileRepository.getUserProfile(uid);
      final name = profile?.displayName.trim() ?? '';
      final gender = profile != null && profile.isProfileComplete
          ? _normalizeGender(profile.gender)
          : '';

      emit(
        _mapState(
          current,
          selfAutofillName: name,
          selfAutofillGender: gender,
          selfAutofillGeneration: current.selfAutofillGeneration + 1,
        ),
      );
    } catch (_) {
      emit(
        _mapState(
          current,
          selfAutofillName: '',
          selfAutofillGender: '',
          selfAutofillGeneration: current.selfAutofillGeneration + 1,
        ),
      );
    }
  }

  static String _normalizeGender(String gender) {
    final value = gender.trim();
    if (value.isEmpty) return '';

    switch (value.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return value;
    }
  }

  BookingState _mapState(
    BookingState current, {
    PatientInfo? patientInfo,
    String? selfAutofillName,
    String? selfAutofillGender,
    int? selfAutofillGeneration,
    bool clearSelfAutofill = false,
    double? walletBalance,
  }) {
    final name = clearSelfAutofill ? null : selfAutofillName ?? current.selfAutofillName;
    final gender =
        clearSelfAutofill ? null : selfAutofillGender ?? current.selfAutofillGender;
    final generation =
        selfAutofillGeneration ?? current.selfAutofillGeneration;
    final balance = walletBalance ?? current.walletBalance;

    if (current is SlotsLoaded) {
      return SlotsLoaded(
        slots: current.slots,
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: patientInfo ?? current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: balance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
        selfAutofillName: name,
        selfAutofillGender: gender,
        selfAutofillGeneration: generation,
        isDoctorAvailable: current.isDoctorAvailable,
        isPastDate: current.isPastDate,
      );
    }

    if (current is BookingLoading) {
      return BookingLoading(
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: patientInfo ?? current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: balance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
        selfAutofillName: name,
        selfAutofillGender: gender,
        selfAutofillGeneration: generation,
      );
    }

    if (current is BookingError) {
      return BookingError(
        message: current.message,
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: patientInfo ?? current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: balance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
        selfAutofillName: name,
        selfAutofillGender: gender,
        selfAutofillGeneration: generation,
      );
    }

    if (current is CardAddingLoading) {
      return CardAddingLoading(
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: patientInfo ?? current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: balance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
        selfAutofillName: name,
        selfAutofillGender: gender,
        selfAutofillGeneration: generation,
      );
    }

    if (current is CardAddingSuccess) {
      return CardAddingSuccess(
        newCard: current.newCard,
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: patientInfo ?? current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: balance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
        selfAutofillName: name,
        selfAutofillGender: gender,
        selfAutofillGeneration: generation,
      );
    }

    if (current is CardAddingFailure) {
      return CardAddingFailure(
        message: current.message,
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: patientInfo ?? current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: balance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
        selfAutofillName: name,
        selfAutofillGender: gender,
        selfAutofillGeneration: generation,
      );
    }

    if (current is BookingConfirming) {
      return BookingConfirming(
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: patientInfo ?? current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: balance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
        selfAutofillName: name,
        selfAutofillGender: gender,
        selfAutofillGeneration: generation,
      );
    }

    if (current is BookingConfirmed) {
      return BookingConfirmed(
        appointmentId: current.appointmentId,
        patientPhone: current.patientPhone,
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: patientInfo ?? current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: balance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
        selfAutofillName: name,
        selfAutofillGender: gender,
        selfAutofillGeneration: generation,
      );
    }

    if (current is BookingConfirmFailure) {
      return BookingConfirmFailure(
        message: current.message,
        selectedDate: current.selectedDate,
        selectedTime: current.selectedTime,
        selectedPackage: current.selectedPackage,
        patientInfo: patientInfo ?? current.patientInfo,
        selectedPaymentMethod: current.selectedPaymentMethod,
        walletBalance: balance,
        savedCards: current.savedCards,
        selectedCardId: current.selectedCardId,
        selfAutofillName: name,
        selfAutofillGender: gender,
        selfAutofillGeneration: generation,
      );
    }

    return BookingInitial(
      selectedDate: current.selectedDate,
      selectedTime: current.selectedTime,
      selectedPackage: current.selectedPackage,
      patientInfo: patientInfo ?? current.patientInfo,
      selectedPaymentMethod: current.selectedPaymentMethod,
      walletBalance: balance,
      savedCards: current.savedCards,
      selectedCardId: current.selectedCardId,
      selfAutofillName: name,
      selfAutofillGender: gender,
      selfAutofillGeneration: generation,
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
          isDoctorAvailable: current.isDoctorAvailable,
          isPastDate: current.isPastDate,
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
          isDoctorAvailable: current.isDoctorAvailable,
          isPastDate: current.isPastDate,
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

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(
        BookingConfirmFailure(
          message: 'No signed-in user. Please sign in and try again.',
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

    final selectedPackage = current.selectedPackage!;
    final patientInfo = current.patientInfo!;
    final selectedPaymentMethod = current.selectedPaymentMethod!;
    final packagePrice = _packagePrice(selectedPackage);
    const discount = bookingDiscount;
    final totalAmount = packagePrice - discount;

    final appointmentData = <String, dynamic>{
      'patientId': uid,
      'doctorId': _activeDoctorId,
      'doctorName': _doctorName,
      'doctorSpecialty': _doctorSpecialty,
      'doctorImage': _doctorImage,
      'doctorRating': _doctorRating,
      'date': Timestamp.fromDate(current.selectedDate),
      'time': current.selectedTime,
      'packageType': selectedPackage.name.toLowerCase(),
      'packageDuration': '30 minutes',
      'packagePrice': packagePrice,
      'patientName': patientInfo.name,
      'patientGender': patientInfo.gender,
      'patientAge': patientInfo.age,
      'paymentMethod': selectedPaymentMethod.name.toLowerCase(),
      'discount': discount,
      'totalAmount': totalAmount,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      if (selectedPaymentMethod == PaymentMethodType.wallet) {
        try {
          await _walletRepository.deductWalletBalance(
            uid,
            totalAmount,
            'Appointment with $_doctorName',
          );
        } catch (e) {
          final message = e.toString().contains('Insufficient wallet balance')
              ? 'Insufficient wallet balance'
              : e.toString();
          emit(
            BookingConfirmFailure(
              message: message,
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
      }

      final appointmentId = await _repository.confirmAppointment(appointmentData);

      try {
        await _notificationRepository.createNotification(
          userId: uid,
          type: 'appointmentConfirmed',
          title: 'Appointment Confirmed!',
          body:
              'Your appointment with $_doctorName has been successfully booked for ${DateFormat('MMM d').format(current.selectedDate)} at ${current.selectedTime}.',
          relatedId: appointmentId,
        );
      } catch (_) {
        // Do not fail booking if notification write fails.
      }

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};
      final patientImage = userData['photoUrl'] as String? ?? '';

      try {
        await _chatRepository.createChat(
          patientId: uid,
          doctorId: _activeDoctorId,
          doctorName: _doctorName,
          doctorImage: _doctorImage,
          doctorSpecialty: _doctorSpecialty,
          patientName: patientInfo.name,
          patientImage: patientImage,
          appointmentId: appointmentId,
        );
      } catch (_) {
        // Do not fail booking if chat creation fails.
      }

      final phone = userData['phone'] as String? ?? '';

      emit(
        BookingConfirmed(
          appointmentId: appointmentId,
          patientPhone: phone,
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
    } catch (e) {
      emit(
        BookingConfirmFailure(
          message: e.toString(),
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
  }

  static double _packagePrice(PackageType package) {
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
        walletBalance: _cachedWalletBalance,
        savedCards: const [],
        selectedCardId: null,
      ),
    );

    await _onFetchAvailableSlots(
      FetchAvailableSlots(_dateOnly(event.date), event.doctorId),
      emit,
    );
  }

  @override
  Future<void> close() {
    unawaited(_walletBalanceSub?.cancel());
    return super.close();
  }
}
