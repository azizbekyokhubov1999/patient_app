import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../domain/entities/appointment.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/filter_result.dart';
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
    this.isLoading = false,
    this.errorMessage,
    this.activeFilter,
  });

  factory HomeState.initial() {
    return const HomeState(
      appointments: [],
      services: [
        Service(title: 'Dentist', icon: LucideIcons.stethoscope),
        Service(title: 'Cardiology', icon: LucideIcons.heartPulse),
        Service(title: 'Neurology', icon: LucideIcons.brain),
        Service(title: 'Orthopedic', icon: LucideIcons.bone),
      ],
      hospitals: [],
      doctors: [],
      selectedServiceIndex: 0,
      currentAppointmentIndex: 0,
      isLoading: true,
    );
  }

  final List<Appointment> appointments;
  final List<Service> services;
  final List<Hospital> hospitals;
  final List<Doctor> doctors;
  final int selectedServiceIndex;
  final int currentAppointmentIndex;
  final bool isLoading;
  final String? errorMessage;
  final FilterResult? activeFilter;

  HomeState copyWith({
    List<Appointment>? appointments,
    List<Service>? services,
    List<Hospital>? hospitals,
    List<Doctor>? doctors,
    int? selectedServiceIndex,
    int? currentAppointmentIndex,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    FilterResult? activeFilter,
  }) {
    return HomeState(
      appointments: appointments ?? this.appointments,
      services: services ?? this.services,
      hospitals: hospitals ?? this.hospitals,
      doctors: doctors ?? this.doctors,
      selectedServiceIndex: selectedServiceIndex ?? this.selectedServiceIndex,
      currentAppointmentIndex:
          currentAppointmentIndex ?? this.currentAppointmentIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  static const Object _sentinel = Object();
}
