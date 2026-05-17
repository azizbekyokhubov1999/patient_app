import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/appointment_model.dart';
import 'cancelled_appointments_state.dart';

/// Demo data while Firestore has no cancelled rows.
const bool _kPresentationMockCancelled = true;

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
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const CancelledAppointmentsInitial());

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  void fetchCancelledAppointments() {
    emit(const CancelledAppointmentsLoading());
    unawaited(_subscription?.cancel());

    if (_kPresentationMockCancelled) {
      emit(CancelledAppointmentsLoaded(_presentationCancelledMocks()));
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(const CancelledAppointmentsLoaded([]));
      return;
    }

    _subscription = _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: uid)
        .where('status', isEqualTo: 'cancelled')
        .snapshots()
        .listen(
      (snapshot) {
        final items = snapshot.docs
            .map(AppointmentModel.fromFirestore)
            .toList()
          ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
        emit(CancelledAppointmentsLoaded(items));
      },
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
