import '../../../home/domain/entities/doctor.dart';

/// Navigation payload for the Consultation Ended screen.
class ConsultationEndedArgs {
  const ConsultationEndedArgs({
    required this.appointmentId,
    required this.doctor,
  });

  final String appointmentId;

  /// Doctor profile shown after the session ends ([Doctor] domain model).
  final Doctor doctor;
}
