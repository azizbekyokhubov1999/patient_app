import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/appointment_model.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(
    this._remoteDataSource, {
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  final BookingRemoteDataSource _remoteDataSource;
  final FirebaseAuth _auth;

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

  @override
  Future<List<TimeSlot>> getDoctorSlots(
    String doctorId,
    DateTime selectedDate,
  ) {
    return _remoteDataSource.getDoctorSlots(doctorId, selectedDate);
  }

  @override
  Future<String> confirmAppointment(Map<String, dynamic> data) async {
    try {
      return await _remoteDataSource.confirmAppointment(data);
    } catch (e) {
      throw Exception('Failed to confirm appointment: $e');
    }
  }

  @override
  Stream<List<AppointmentModel>> getUpcomingAppointments() {
    final uid = _auth.currentUser!.uid;
    return _remoteDataSource.getUpcomingAppointments(uid);
  }

  @override
  Stream<List<AppointmentModel>> getCompletedAppointments() {
    final uid = _auth.currentUser!.uid;
    return _remoteDataSource.getCompletedAppointments(uid);
  }

  @override
  Stream<List<AppointmentModel>> getCancelledAppointments() {
    final uid = _auth.currentUser!.uid;
    return _remoteDataSource.getCancelledAppointments(uid);
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _remoteDataSource.cancelAppointment(appointmentId);
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> autoCompleteExpiredAppointments() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Future.value(const []);
    return _remoteDataSource.autoCompleteExpiredAppointments(uid);
  }
}