import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/appointment_model.dart';
import '../../domain/repositories/booking_repository.dart';
import 'cancelled_appointments_state.dart';

/// Demo data reference (disabled — live Firestore is used).
const bool _kPresentationMockCancelled = false;

List<AppointmentModel> _presentationCancelledMocks() {
  return [
    AppointmentModel(
      documentId: 'mock-cancelled-1',
      appointmentId: 'DC857496',
      doctorId: 'mock-dr-brown',
      doctorName: 'Dr. Jessica Brown',
      doctorSpecialty: 'Rhinology',
      doctorRating: 4.7,
      doctorImageUrl: 'https://picsum.photos/200?brown',
      appointmentDate: DateTime(2025, 11, 10),
      startTime: '10:00',
      endTime: '10:30',
      status: 'cancelled',
      remindEnabled: false,
    ),
    AppointmentModel(
      documentId: 'mock-cancelled-2',
      appointmentId: 'DC857497',
      doctorId: 'mock-dr-jenny',
      doctorName: 'Dr. Jenny William',
      doctorSpecialty: 'Dentist',
      doctorRating: 4.9,
      doctorImageUrl: 'https://picsum.photos/200?jenny',
      appointmentDate: DateTime(2025, 10, 28),
      startTime: '11:30',
      endTime: '12:00',
      status: 'cancelled',
      remindEnabled: false,
    ),
  ];
}

class CancelledAppointmentsCubit extends Cubit<CancelledAppointmentsState> {
  CancelledAppointmentsCubit({
    BookingRepository? repository,
    FirebaseAuth? auth,
  })  : _repository = repository ??
            BookingRepositoryImpl(
              BookingRemoteDataSourceImpl(),
              auth: auth,
            ),
        _auth = auth ?? FirebaseAuth.instance,
        super(const CancelledAppointmentsInitial());

  final BookingRepository _repository;
  final FirebaseAuth _auth;

  StreamSubscription<List<AppointmentModel>>? _subscription;

  void fetchCancelledAppointments() {
    emit(const CancelledAppointmentsLoading());
    unawaited(_subscription?.cancel());

    if (_kPresentationMockCancelled) {
      emit(CancelledAppointmentsLoaded(_presentationCancelledMocks()));
      return;
    }

    if (_auth.currentUser == null) {
      emit(const CancelledAppointmentsLoaded([]));
      return;
    }

    _subscription = _repository.getCancelledAppointments().listen(
      (appointments) => emit(CancelledAppointmentsLoaded(appointments)),
      onError: (Object e, StackTrace st) {
        emit(CancelledAppointmentsError(e.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
