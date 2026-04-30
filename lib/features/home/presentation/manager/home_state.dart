import '../../domain/entities/appointment.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/service.dart';

class HomeState {
  const HomeState({
    required this.appointments,
    required this.services,
    required this.hospitals,
    required this.doctors,
    required this.selectedServiceIndex,
    required this.currentAppointmentIndex,
  });

  final List<Appointment> appointments;
  final List<Service> services;
  final List<Hospital> hospitals;
  final List<Doctor> doctors;
  final int selectedServiceIndex;
  final int currentAppointmentIndex;

  HomeState copyWith({
    List<Appointment>? appointments,
    List<Service>? services,
    List<Hospital>? hospitals,
    List<Doctor>? doctors,
    int? selectedServiceIndex,
    int? currentAppointmentIndex,
  }) {
    return HomeState(
      appointments: appointments ?? this.appointments,
      services: services ?? this.services,
      hospitals: hospitals ?? this.hospitals,
      doctors: doctors ?? this.doctors,
      selectedServiceIndex: selectedServiceIndex ?? this.selectedServiceIndex,
      currentAppointmentIndex:
          currentAppointmentIndex ?? this.currentAppointmentIndex,
    );
  }
}
