class Appointment {
  const Appointment({
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.dateLabel,
    required this.timeLabel,
  });

  final String doctorName;
  final String specialty;
  final double rating;
  final String dateLabel;
  final String timeLabel;
}
