import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/appointment.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit()
    : super(
        HomeState(
          appointments: const [
            Appointment(
              doctorName: 'Dr. Jenny William',
              specialty: 'Dentist',
              rating: 4.9,
              dateLabel: 'Tuesday, 20 January',
              timeLabel: '09:00 - 10:00',
            ),
            Appointment(
              doctorName: 'Dr. Amelia Collins',
              specialty: 'Cardiologist',
              rating: 4.8,
              dateLabel: 'Wednesday, 21 January',
              timeLabel: '11:00 - 12:00',
            ),
            Appointment(
              doctorName: 'Dr. James Miller',
              specialty: 'Neurologist',
              rating: 5.0,
              dateLabel: 'Thursday, 22 January',
              timeLabel: '14:00 - 15:00',
            ),
          ],
          services: const [
            Service(title: 'Dentist', icon: Icons.medical_services_outlined),
            Service(title: 'Cardiology', icon: Icons.favorite_outline),
            Service(title: 'Neurology', icon: Icons.psychology_outlined),
            Service(
              title: 'Orthopedic',
              icon: Icons.accessibility_new_outlined,
            ),
          ],
          hospitals: const [
            Hospital(
              name: 'Unity Health Hospital',
              rating: 4.8,
              tags: 'Dentist, Ophthalmologist, Otology',
              address: '6391 Elgin St. Celina, Delaware 10299',
              distance: '3.5 Miles',
              eta: '15 Min',
              imageUrl:
                  'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=1200&q=80',
            ),
            Hospital(
              name: 'Elite Care Center',
              rating: 4.7,
              tags: 'Cardiology, Pediatric',
              address: '8502 Preston Rd. Inglewood, Maine',
              distance: '2.1 Miles',
              eta: '9 Min',
              imageUrl:
                  'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
            ),
          ],
          doctors: const [
            Doctor(
              name: 'Dr. Sophia Rossi',
              specialty: 'Otology Specialist',
              rating: 4.9,
              reviews: 53,
              imageUrl:
                  'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=800&q=80',
            ),
            Doctor(
              name: 'Dr. Robert Fox',
              specialty: 'Dentist',
              rating: 5.0,
              reviews: 12,
              imageUrl:
                  'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=800&q=80',
            ),
            Doctor(
              name: 'Dr. James Chen',
              specialty: 'Radiologist Specialist',
              rating: 4.9,
              reviews: 49,
              imageUrl:
                  'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=800&q=80',
            ),
            Doctor(
              name: 'Dr. Robert Martinez',
              specialty: 'Rhinologist',
              rating: 5.0,
              reviews: 24,
              imageUrl:
                  'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=800&q=80',
            ),
          ],
          selectedServiceIndex: 0,
          currentAppointmentIndex: 0,
        ),
      );

  void selectService(int index) {
    emit(state.copyWith(selectedServiceIndex: index));
  }

  void updateCurrentAppointment(int index) {
    emit(state.copyWith(currentAppointmentIndex: index));
  }
}
