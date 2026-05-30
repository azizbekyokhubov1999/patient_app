enum TimeSlotStatus { available, reserved, selected }

class TimeSlot {
  const TimeSlot({
    required this.time,
    required this.status,
    bool? isAvailable,
  }) : isAvailable = isAvailable ?? status != TimeSlotStatus.reserved;

  final String time;
  final TimeSlotStatus status;
  final bool isAvailable;

  TimeSlot copyWith({
    String? time,
    TimeSlotStatus? status,
    bool? isAvailable,
  }) {
    final nextStatus = status ?? this.status;
    return TimeSlot(
      time: time ?? this.time,
      status: nextStatus,
      isAvailable: isAvailable ??
          (nextStatus == TimeSlotStatus.reserved ? false : this.isAvailable),
    );
  }
}
