import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/appointment_preview.dart';
import 'upcoming_appointment_state.dart';

/// Presentation / demo bypass (no Firestore).
const bool _kPresentationMockAppointments = true;

/// Next Monday strictly after [from] calendar day when [from] falls on Monday
/// jumps one week ahead.
DateTime _nextMondayFrom(DateTime from) {
  final day = DateTime(from.year, from.month, from.day);
  final w = day.weekday;
  if (w == DateTime.monday) {
    return day.add(const Duration(days: 7));
  }
  final add = (DateTime.monday - w + 7) % 7;
  return day.add(Duration(days: add == 0 ? 7 : add));
}

List<AppointmentPreview> _presentationAppointmentsMocks() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final dayAfter = today.add(const Duration(days: 2));
  final nextMon = _nextMondayFrom(now);

  return [
    AppointmentPreview(
      appointmentId: 'mock-apt-1',
      doctorName: 'Dr. Jenny Wilson',
      doctorSpecialty: 'Dentist',
      doctorRating: 4.9,
      doctorImageUrl: 'https://picsum.photos/200',
      appointmentDate: tomorrow,
      startTime: '09:00',
      endTime: '10:00',
      status: 'confirmed',
    ),
    AppointmentPreview(
      appointmentId: 'mock-apt-2',
      doctorName: 'Dr. Olivia Brown',
      doctorSpecialty: 'Otology',
      doctorRating: 4.8,
      doctorImageUrl: 'https://picsum.photos/200',
      appointmentDate: dayAfter,
      startTime: '15:00',
      endTime: '15:30',
      status: 'confirmed',
    ),
    AppointmentPreview(
      appointmentId: 'mock-apt-3',
      doctorName: 'Dr. Alex Patel',
      doctorSpecialty: 'Cardiology',
      doctorRating: 4.7,
      doctorImageUrl: 'https://picsum.photos/200',
      appointmentDate: nextMon,
      startTime: '11:00',
      endTime: '12:00',
      status: 'confirmed',
    ),
  ];
}

class UpcomingAppointmentCubit extends Cubit<UpcomingAppointmentState> {
  UpcomingAppointmentCubit() : super(const UpcomingAppointmentInitial());

  Future<void> loadUpcomingAppointments() async {
    if (_kPresentationMockAppointments) {
      final mocks = _presentationAppointmentsMocks();
      emit(
        UpcomingAppointmentLoaded(
          appointments: mocks,
          filteredAppointments: List<AppointmentPreview>.from(mocks),
        ),
      );
      return;
    }
    emit(const UpcomingAppointmentEmpty());
  }

  /// Pull-to-refresh: mirrors [loadUpcomingAppointments] for mocks.
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
