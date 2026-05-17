import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/appointment_model.dart';
import 'completed_appointments_state.dart';

/// Demo data while Firestore has no completed rows.
const bool _kPresentationMockCompleted = true;

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
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const CompletedAppointmentsInitial());

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  void fetchCompletedAppointments() {
    emit(const CompletedAppointmentsLoading());
    unawaited(_subscription?.cancel());

    if (_kPresentationMockCompleted) {
      emit(CompletedAppointmentsLoaded(_presentationCompletedMocks()));
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(const CompletedAppointmentsLoaded([]));
      return;
    }

    _subscription = _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .listen(
      (snapshot) {
        final items = snapshot.docs
            .map(AppointmentModel.fromFirestore)
            .toList()
          ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
        emit(CompletedAppointmentsLoaded(items));
      },
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
