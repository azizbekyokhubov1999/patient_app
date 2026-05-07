import '../entities/time_slot.dart';

abstract class BookingRepository {
  Future<List<TimeSlot>> fetchAvailableSlots({
    required DateTime date,
    required String doctorId,
  });
}
