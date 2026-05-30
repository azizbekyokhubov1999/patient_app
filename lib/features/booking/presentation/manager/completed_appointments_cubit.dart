import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/appointment_model.dart';
import '../../domain/repositories/booking_repository.dart';
import 'completed_appointments_state.dart';

/// Demo data reference (disabled — live Firestore is used).
const bool _kPresentationMockCompleted = false;

List<AppointmentModel> _presentationCompletedMocks() {
  return [
    AppointmentModel(
      documentId: 'mock-completed-1',
      appointmentId: 'DC854687',
      doctorId: 'mock-dr-chen',
      doctorName: 'Dr. James Chen',
      doctorSpecialty: 'Radiologist Specialist',
      doctorRating: 4.9,
      doctorImageUrl: 'https://picsum.photos/200?chen',
      appointmentDate: DateTime(2025, 12, 10),
      startTime: '10:00',
      endTime: '10:30',
      status: 'completed',
      remindEnabled: false,
    ),
    AppointmentModel(
      documentId: 'mock-completed-2',
      appointmentId: 'DC854688',
      doctorId: 'mock-dr-martinez',
      doctorName: 'Dr. Robert Martinez',
      doctorSpecialty: 'Rhinology',
      doctorRating: 5,
      doctorImageUrl: 'https://picsum.photos/200?martinez',
      appointmentDate: DateTime(2025, 11, 22),
      startTime: '14:00',
      endTime: '14:45',
      status: 'completed',
      remindEnabled: false,
    ),
  ];
}

class CompletedAppointmentsCubit extends Cubit<CompletedAppointmentsState> {
  CompletedAppointmentsCubit({
    BookingRepository? repository,
    FirebaseAuth? auth,
  })  : _repository = repository ??
            BookingRepositoryImpl(
              BookingRemoteDataSourceImpl(),
              auth: auth,
            ),
        _auth = auth ?? FirebaseAuth.instance,
        super(const CompletedAppointmentsInitial());

  final BookingRepository _repository;
  final FirebaseAuth _auth;

  StreamSubscription<List<AppointmentModel>>? _subscription;

  void addCompleted(AppointmentModel appointment) {
    final current = state;
    if (current is! CompletedAppointmentsLoaded) {
      emit(CompletedAppointmentsLoaded([appointment]));
      return;
    }

    final exists = current.appointments.any(
      (a) => a.documentId == appointment.documentId,
    );
    if (exists) return;

    final updated = [appointment, ...current.appointments];
    emit(CompletedAppointmentsLoaded(updated));
  }

  void fetchCompletedAppointments() {
    emit(const CompletedAppointmentsLoading());
    unawaited(_subscription?.cancel());

    if (_kPresentationMockCompleted) {
      emit(CompletedAppointmentsLoaded(_presentationCompletedMocks()));
      return;
    }

    if (_auth.currentUser == null) {
      emit(const CompletedAppointmentsLoaded([]));
      return;
    }

    _subscription = _repository.getCompletedAppointments().listen(
      (appointments) => emit(CompletedAppointmentsLoaded(appointments)),
      onError: (Object e, StackTrace st) {
        emit(CompletedAppointmentsError(e.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
