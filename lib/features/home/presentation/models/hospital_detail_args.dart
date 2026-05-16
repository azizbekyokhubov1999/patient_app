import '../../domain/entities/hospital.dart';

class HospitalDetailArgs {
  const HospitalDetailArgs({
    required this.hospitalId,
    this.hospital,
  });

  final String hospitalId;

  /// When opening from Nearby Hospitals, pass the loaded model so detail stays rich.
  final Hospital? hospital;
}
