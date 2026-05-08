import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/hospital.dart';
import '../models/booking_route_args.dart';

abstract final class BookingNavigation {
  static Future<T?> startBooking<T>(
    BuildContext context, {
    Doctor? doctor,
    Hospital? hospital,
    Doctor? selectedSpecialist,
    String? doctorId,
  }) {
    return context.pushNamed<T>(
      'book-appointment',
      extra: BookingRouteArgs(
        doctor: doctor,
        doctorId: doctorId,
        hospital: hospital,
        selectedSpecialist: selectedSpecialist,
      ),
    );
  }

  static void openAppointmentsTab(BuildContext context) {
    context.go(AppPaths.booking);
  }
}
