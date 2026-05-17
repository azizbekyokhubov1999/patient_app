import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/appointment_model.dart';
import 'upcoming_appointments_state.dart';

/// Demo data while Firestore has no rows (presentation).
const bool _kPresentationMockAppointments = true;

List<AppointmentModel> _presentationUpcomingMocks() {
  return [
    AppointmentModel(
      documentId: 'mock-apt-1',
      appointmentId: 'DC854568',
      doctorName: 'Dr. Jenny William',
      doctorSpecialty: 'Dentist',
      doctorRating: 4.9,
      doctorImageUrl: 'https://picsum.photos/200?jenny',
      appointmentDate: DateTime(2026, 1, 15),
      startTime: '11:00',
      endTime: '12:00',
      status: 'upcoming',
      remindEnabled: true,
    ),
    AppointmentModel(
      documentId: 'mock-apt-2',
      appointmentId: 'DC854569',
      doctorName: 'Dr. Sophia Rossi',
      doctorSpecialty: 'Otology Specialist',
      doctorRating: 4.8,
      doctorImageUrl: 'https://picsum.photos/200?sophia',
      appointmentDate: DateTime(2026, 1, 18),
      startTime: '15:00',
      endTime: '15:30',
      status: 'upcoming',
      remindEnabled: false,
    ),
  ];
}

class UpcomingAppointmentsCubit extends Cubit<UpcomingAppointmentsState> {
  UpcomingAppointmentsCubit({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const UpcomingAppointmentsInitial());

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  void fetchUpcomingAppointments() {
    emit(const UpcomingAppointmentsLoading());
    unawaited(_subscription?.cancel());

    if (_kPresentationMockAppointments) {
      emit(UpcomingAppointmentsLoaded(_presentationUpcomingMocks()));
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(const UpcomingAppointmentsLoaded([]));
      return;
    }

    _subscription = _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: uid)
        .where('status', whereIn: ['upcoming', 'confirmed'])
        .snapshots()
        .listen(
      (snapshot) {
        final items = snapshot.docs
            .map(AppointmentModel.fromFirestore)
            .toList()
          ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
        emit(UpcomingAppointmentsLoaded(items));
      },
      onError: (Object e, StackTrace st) {
        emit(UpcomingAppointmentsError(e.toString()));
      },
    );
  }

  Future<void> toggleReminder(String appointmentId, bool isEnabled) async {
    final current = state;
    if (current is! UpcomingAppointmentsLoaded) return;

    if (!_kPresentationMockAppointments) {
      try {
        await _firestore
            .collection('appointments')
            .doc(_documentIdFor(appointmentId, current))
            .update({'remindEnabled': isEnabled});
      } catch (e) {
        emit(UpcomingAppointmentsError(e.toString()));
        return;
      }
    }

    final updated = current.appointments
        .map(
          (a) => _matchesId(a, appointmentId)
              ? a.copyWith(remindEnabled: isEnabled)
              : a,
        )
        .toList();
    emit(UpcomingAppointmentsLoaded(updated));

    if (isEnabled) {
      developer.log(
        'Reminder enabled for $appointmentId (local notification placeholder)',
        name: 'UpcomingAppointmentsCubit',
      );
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    final current = state;
    if (current is! UpcomingAppointmentsLoaded) return;

    if (!_kPresentationMockAppointments) {
      try {
        await _firestore
            .collection('appointments')
            .doc(_documentIdFor(appointmentId, current))
            .update({'status': 'cancelled'});
      } catch (e) {
        emit(UpcomingAppointmentsError(e.toString()));
        return;
      }
    }

    final remaining = current.appointments
        .where((a) => !_matchesId(a, appointmentId))
        .toList();
    emit(UpcomingAppointmentsLoaded(remaining));
  }

  String _documentIdFor(
    String appointmentId,
    UpcomingAppointmentsLoaded current,
  ) {
    for (final a in current.appointments) {
      if (_matchesId(a, appointmentId)) return a.documentId;
    }
    return appointmentId;
  }

  bool _matchesId(AppointmentModel a, String id) =>
      a.appointmentId == id || a.documentId == id;

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
