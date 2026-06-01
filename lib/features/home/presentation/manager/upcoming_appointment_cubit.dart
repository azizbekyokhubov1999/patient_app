import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/appointment_preview.dart';
import '../../domain/repositories/home_repository.dart';
import 'upcoming_appointment_state.dart';

class UpcomingAppointmentCubit extends Cubit<UpcomingAppointmentState> {
  UpcomingAppointmentCubit({
    required HomeRepository repository,
    FirebaseAuth? auth,
  })  : _repository = repository,
        _auth = auth ?? FirebaseAuth.instance,
        super(const UpcomingAppointmentInitial());

  final HomeRepository _repository;
  final FirebaseAuth _auth;

  Future<void> loadUpcomingAppointments() async {
    emit(const UpcomingAppointmentLoading());

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(
        const UpcomingAppointmentError(
          'No signed-in user. Please sign in and try again.',
        ),
      );
      return;
    }

    try {
      final appointments =
          await _repository.getAllUpcomingAppointments(uid);

      if (appointments.isEmpty) {
        emit(const UpcomingAppointmentEmpty());
        return;
      }

      emit(
        UpcomingAppointmentLoaded(
          appointments: appointments,
          filteredAppointments: List<AppointmentPreview>.from(appointments),
        ),
      );
    } catch (e) {
      emit(UpcomingAppointmentError(e.toString()));
    }
  }

  Future<void> refresh() => loadUpcomingAppointments();

  void filterByQuery(String query) {
    final current = state;
    if (current is! UpcomingAppointmentLoaded) return;

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(
        UpcomingAppointmentLoaded(
          appointments: current.appointments,
          filteredAppointments: List<AppointmentPreview>.from(
            current.appointments,
          ),
        ),
      );
      return;
    }

    final lower = trimmed.toLowerCase();
    final filtered = current.appointments.where((a) {
      return a.doctorName.toLowerCase().contains(lower) ||
          a.doctorSpecialty.toLowerCase().contains(lower);
    }).toList();

    emit(
      UpcomingAppointmentLoaded(
        appointments: current.appointments,
        filteredAppointments: filtered,
      ),
    );
  }
}
