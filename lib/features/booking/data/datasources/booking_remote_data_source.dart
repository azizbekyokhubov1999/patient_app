import '../../domain/entities/time_slot.dart';

abstract class BookingRemoteDataSource {
  Future<List<TimeSlot>> fetchAvailableSlots({
    required DateTime date,
    required String doctorId,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  static const List<String> _times = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
  ];

  @override
  Future<List<TimeSlot>> fetchAvailableSlots({
    required DateTime date,
    required String doctorId,
  }) async {
    final seed = date.day + date.month + date.year + doctorId.length;

    return _times.asMap().entries.map((entry) {
      final reserved = (entry.key + seed) % 7 == 0 || (entry.key + seed) % 11 == 0;
      return TimeSlot(
        time: entry.value,
        status: reserved ? TimeSlotStatus.reserved : TimeSlotStatus.available,
      );
    }).toList();
  }
}
