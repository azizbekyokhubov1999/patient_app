import '../../../home/domain/entities/doctor.dart';

/// Navigation payload for the Consultation Ended screen.
class ConsultationEndedArgs {
  const ConsultationEndedArgs({
    required this.appointmentId,
    required this.doctor,
    this.documentId,
  });

  final String appointmentId;

  /// Firestore / mock document id used to move the card to Completed.
  final String? documentId;

  /// Doctor profile shown after the session ends ([Doctor] domain model).
  final Doctor doctor;
}
