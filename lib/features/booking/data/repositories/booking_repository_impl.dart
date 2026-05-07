import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._remoteDataSource);

  final BookingRemoteDataSource _remoteDataSource;

  @override
  Future<List<TimeSlot>> fetchAvailableSlots({
    required DateTime date,
    required String doctorId,
  }) {
    return _remoteDataSource.fetchAvailableSlots(
      date: date,
      doctorId: doctorId,
    );
  }
}
