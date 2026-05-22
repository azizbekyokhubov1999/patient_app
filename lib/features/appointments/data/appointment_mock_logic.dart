import 'package:cloud_firestore/cloud_firestore.dart';

import '../../booking/domain/entities/appointment_model.dart';
import '../../home/presentation/manager/get_direction_args.dart';

/// Mock helpers for offline navigation and demo session transitions.
abstract final class AppointmentMockLogic {
  AppointmentMockLogic._();

  static const GeoPoint kDemoHospitalGeo = GeoPoint(37.7749, -122.4194);

  static GetDirectionArgs directionArgsFor(AppointmentModel appointment) {
    return GetDirectionArgs(
      hospitalId: appointment.hospitalId ?? 'demo-hospital',
      hospitalName: appointment.doctorName,
      geoPoint: kDemoHospitalGeo,
      hospitalAddress: appointment.hospitalAddress.isNotEmpty
          ? appointment.hospitalAddress
          : '6391 Elgin St. Celina, Delaware 10299',
    );
  }

  /// Demo: doctor started an online session (enables Join Session on the card).
  static AppointmentModel withDoctorStarted(AppointmentModel appointment) {
    return appointment.copyWith(sessionStatus: 'started_by_doctor');
  }

  /// Demo: doctor marked the consultation complete (triggers feedback flow).
  static AppointmentModel withSessionCompleted(AppointmentModel appointment) {
    return appointment.copyWith(
      sessionStatus: 'completed',
      status: 'completed',
    );
  }
}
