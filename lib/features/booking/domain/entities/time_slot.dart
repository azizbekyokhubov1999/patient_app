enum TimeSlotStatus { available, reserved, selected }

class TimeSlot {
  const TimeSlot({
    required this.time,
    required this.status,
  });

  final String time;
  final TimeSlotStatus status;

  TimeSlot copyWith({
    String? time,
    TimeSlotStatus? status,
  }) {
    return TimeSlot(
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }
}
