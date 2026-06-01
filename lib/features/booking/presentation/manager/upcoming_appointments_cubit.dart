import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/appointment_model.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../../appointments/data/appointment_mock_logic.dart';
import 'upcoming_appointments_state.dart';

/// Demo data reference (disabled — live Firestore is used).
const bool kPresentationMockAppointments = false;

String _formatTime(DateTime time) => DateFormat('HH:mm').format(time);

List<AppointmentModel> _presentationUpcomingMocks() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return [
    AppointmentModel(
      documentId: 'mock-apt-offline-direction',
      appointmentId: 'DC854568',
      doctorName: 'Dr. Jenny William',
      doctorSpecialty: 'Dentist',
      doctorRating: 4.9,
      doctorImageUrl: 'https://picsum.photos/200?jenny',
      appointmentDate: today,
      startTime: _formatTime(now.add(const Duration(minutes: 45))),
      endTime: _formatTime(now.add(const Duration(hours: 1, minutes: 45))),
      status: 'confirmed',
      remindEnabled: true,
      type: 'offline',
      sessionStatus: 'pending',
      hospitalAddress: '6391 Elgin St. Celina, Delaware 10299',
      hospitalId: 'hospital-celina',
      packageType: 'In-Person',
      packageDuration: '45 minutes',
    ),
    AppointmentModel(
      documentId: 'mock-apt-offline-scan',
      appointmentId: 'DC854569',
      doctorName: 'Dr. Sophia Rossi',
      doctorSpecialty: 'Otology Specialist',
      doctorRating: 4.8,
      doctorImageUrl: 'https://picsum.photos/200?sophia',
      appointmentDate: today,
      startTime: _formatTime(now.add(const Duration(minutes: 3))),
      endTime: _formatTime(now.add(const Duration(minutes: 33))),
      status: 'confirmed',
      remindEnabled: false,
      type: 'offline',
      sessionStatus: 'pending',
      hospitalAddress: '4517 Washington Ave. Manchester, Kentucky 39495',
      hospitalId: 'hospital-manchester',
      packageType: 'In-Person',
      packageDuration: '30 minutes',
    ),
    AppointmentModel(
      documentId: 'mock-apt-video-join',
      appointmentId: 'DC854570',
      doctorName: 'Dr. James Chen',
      doctorSpecialty: 'Radiologist Specialist',
      doctorRating: 4.9,
      doctorImageUrl: 'https://picsum.photos/200?chen',
      appointmentDate: today,
      startTime: _formatTime(now),
      endTime: _formatTime(now.add(const Duration(minutes: 30))),
      status: 'confirmed',
      remindEnabled: true,
      type: 'video',
      sessionStatus: 'started_by_doctor',
      packageType: 'Video',
      packageDuration: '30 minutes',
      doctorId: 'mock-dr-chen',
    ),
  ];
}

class UpcomingAppointmentsCubit extends Cubit<UpcomingAppointmentsState> {
  UpcomingAppointmentsCubit({
    BookingRepository? repository,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _repository = repository ??
            BookingRepositoryImpl(
              BookingRemoteDataSourceImpl(firestore: firestore),
              auth: auth,
            ),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const UpcomingAppointmentsInitial());

  final BookingRepository _repository;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<List<AppointmentModel>>? _subscription;
  Timer? _timeRefreshTimer;
  final Set<String> _autoCompleteNotifiedIds = {};

  void startTimeRefreshTimer() {
    if (_timeRefreshTimer != null) return;
    _timeRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      unawaited(_runAutoComplete());
      _emitTimeRefreshTick();
    });
  }

  void _emitTimeRefreshTick() {
    final current = state;
    if (current is! UpcomingAppointmentsLoaded) return;
    emit(
      UpcomingAppointmentsLoaded(
        current.appointments,
        appointmentPendingConsultationEnd:
            current.appointmentPendingConsultationEnd,
      ),
    );
  }

  void fetchUpcomingAppointments() {
    emit(const UpcomingAppointmentsLoading());
    unawaited(_subscription?.cancel());

    if (kPresentationMockAppointments) {
      emit(UpcomingAppointmentsLoaded(_presentationUpcomingMocks()));
      return;
    }

    if (_auth.currentUser == null) {
      emit(const UpcomingAppointmentsLoaded([]));
      return;
    }

    unawaited(_runAutoComplete());

    _subscription = _repository.getUpcomingAppointments().listen(
      (appointments) async {
        await _runAutoComplete();
        final current = state;
        final pending = current is UpcomingAppointmentsLoaded
            ? current.appointmentPendingConsultationEnd
            : null;
        emit(
          UpcomingAppointmentsLoaded(
            appointments,
            appointmentPendingConsultationEnd: pending,
          ),
        );
        startTimeRefreshTimer();
      },
      onError: (Object e, StackTrace st) {
        emit(UpcomingAppointmentsError(e.toString()));
      },
    );
  }

  /// Returns appointment to show on [ConsultationEndedPage], if any were newly completed.
  Future<AppointmentModel?> _runAutoComplete() async {
    if (kPresentationMockAppointments || _auth.currentUser == null) {
      return null;
    }

    try {
      final completed = await _repository.autoCompleteExpiredAppointments();
      if (completed.isEmpty) return null;

      AppointmentModel? mostRecent;
      for (final appointment in completed) {
        if (_autoCompleteNotifiedIds.contains(appointment.documentId)) {
          continue;
        }
        _autoCompleteNotifiedIds.add(appointment.documentId);
        mostRecent = appointment;
        break;
      }

      if (mostRecent != null) {
        final current = state;
        if (current is UpcomingAppointmentsLoaded) {
          emit(
            current.copyWith(appointmentPendingConsultationEnd: mostRecent),
          );
        }
      }

      return mostRecent;
    } catch (e, st) {
      developer.log(
        'autoCompleteExpiredAppointments error',
        error: e,
        stackTrace: st,
        name: 'UpcomingAppointmentsCubit',
      );
      return null;
    }
  }

  void clearPendingConsultationEnd() {
    final current = state;
    if (current is! UpcomingAppointmentsLoaded) return;
    if (current.appointmentPendingConsultationEnd == null) return;
    emit(current.copyWith(clearPendingConsultationEnd: true));
  }

  void updateSessionStatus(String documentId, String sessionStatus) {
    final current = state;
    if (current is! UpcomingAppointmentsLoaded) return;

    final updated = current.appointments
        .map(
          (a) => a.documentId == documentId
              ? a.copyWith(sessionStatus: sessionStatus)
              : a,
        )
        .toList();
    emit(UpcomingAppointmentsLoaded(updated));
  }

  /// Demo: doctor started the online session.
  void simulateDoctorStarted(String documentId) {
    updateSessionStatus(documentId, 'started_by_doctor');
  }

  /// Marks session complete and signals navigation to feedback.
  AppointmentModel? completeAppointment(String documentId) {
    final current = state;
    if (current is! UpcomingAppointmentsLoaded) return null;

    AppointmentModel? completed;
    final remaining = <AppointmentModel>[];

    for (final a in current.appointments) {
      if (a.documentId == documentId) {
        completed = AppointmentMockLogic.withSessionCompleted(a);
      } else {
        remaining.add(a);
      }
    }

    if (completed == null) return null;

    emit(
      UpcomingAppointmentsLoaded(
        remaining,
        appointmentPendingConsultationEnd: completed,
      ),
    );

    developer.log(
      'Consultation completed for ${completed.displayAppointmentId}',
      name: 'UpcomingAppointmentsCubit',
    );

    return completed;
  }

  Future<void> toggleReminder(String appointmentId, bool isEnabled) async {
    final current = state;
    if (current is! UpcomingAppointmentsLoaded) return;

    if (!kPresentationMockAppointments) {
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

  Future<bool> cancelAppointment(String appointmentId) async {
    final current = state;
    if (current is! UpcomingAppointmentsLoaded) return false;

    final docId = _documentIdFor(appointmentId, current);

    if (kPresentationMockAppointments) {
      final remaining = current.appointments
          .where((a) => !_matchesId(a, appointmentId))
          .toList();
      emit(UpcomingAppointmentsLoaded(remaining));
      return true;
    }

    try {
      await _repository.cancelAppointment(docId);
      return true;
    } catch (e, st) {
      developer.log('cancelAppointment error', error: e, stackTrace: st);
      emit(
        const UpcomingAppointmentsError(
          'Failed to cancel appointment. Please try again.',
        ),
      );
      return false;
    }
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
    _timeRefreshTimer?.cancel();
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
