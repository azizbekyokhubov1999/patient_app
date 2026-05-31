import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/appointment_model.dart';
import '../../domain/entities/time_slot.dart';

abstract class BookingRemoteDataSource {
  Future<List<TimeSlot>> fetchAvailableSlots({
    required DateTime date,
    required String doctorId,
  });

  Future<List<TimeSlot>> getDoctorSlots(String doctorId, DateTime selectedDate);

  Future<String> confirmAppointment(Map<String, dynamic> data);

  Stream<List<AppointmentModel>> getUpcomingAppointments(String uid);

  Stream<List<AppointmentModel>> getCompletedAppointments(String uid);

  Stream<List<AppointmentModel>> getCancelledAppointments(String uid);

  Future<void> cancelAppointment(String appointmentId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  BookingRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const List<String> _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Future<List<TimeSlot>> fetchAvailableSlots({
    required DateTime date,
    required String doctorId,
  }) {
    return getDoctorSlots(doctorId, date);
  }

  @override
  Future<List<TimeSlot>> getDoctorSlots(
    String doctorId,
    DateTime selectedDate,
  ) async {
    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final weekdayName = _weekdayNames[date.weekday - 1];

    final doctorDoc = await _firestore.collection('doctors').doc(doctorId).get();
    if (!doctorDoc.exists) {
      return const [];
    }

    final doctorData = doctorDoc.data() ?? {};
    final workDays = (doctorData['workDays'] as List<dynamic>?)
            ?.map((day) => day.toString())
            .toList() ??
        const [];

    if (!workDays.contains(weekdayName)) {
      return const [];
    }

    final workStartTime = doctorData['workStartTime'] as String? ?? '09:00';
    final workEndTime = doctorData['workEndTime'] as String? ?? '17:00';
    final slotDurationMinutes =
        (doctorData['slotDurationMinutes'] as num?)?.toInt() ?? 30;

    final slotTimes = _generateSlotTimes(
      startTime: workStartTime,
      endTime: workEndTime,
      durationMinutes: slotDurationMinutes,
    );

    if (slotTimes.isEmpty) {
      return const [];
    }

    final bookedTimes = await _fetchBookedTimes(doctorId, date);

    return slotTimes
        .map((time) {
          final isBooked = bookedTimes.contains(time);
          return TimeSlot(
            time: time,
            isAvailable: !isBooked,
            status: isBooked ? TimeSlotStatus.reserved : TimeSlotStatus.available,
          );
        })
        .toList(growable: false);
  }

  Future<Set<String>> _fetchBookedTimes(String doctorId, DateTime date) async {
    final startOfDay = Timestamp.fromDate(
      DateTime(date.year, date.month, date.day),
    );
    final endOfDay = Timestamp.fromDate(
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999),
    );

    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .where('status', isEqualTo: 'confirmed')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['time'] as String? ?? '')
          .where((time) => time.isNotEmpty)
          .toSet();
    } catch (_) {
      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'confirmed')
          .get();

      return snapshot.docs
          .where((doc) {
            final appointmentDate = doc.data()['date'];
            if (appointmentDate is! Timestamp) return false;
            final aptDate = appointmentDate.toDate();
            return aptDate.year == date.year &&
                aptDate.month == date.month &&
                aptDate.day == date.day;
          })
          .map((doc) => doc.data()['time'] as String? ?? '')
          .where((time) => time.isNotEmpty)
          .toSet();
    }
  }

  List<String> _generateSlotTimes({
    required String startTime,
    required String endTime,
    required int durationMinutes,
  }) {
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    if (start == null || end == null || !start.isBefore(end)) {
      return const [];
    }

    final slots = <String>[];
    var current = start;
    while (current.isBefore(end)) {
      slots.add(_formatTime(current));
      current = current.add(Duration(minutes: durationMinutes));
    }
    return slots;
  }

  DateTime? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return DateTime(2000, 1, 1, hour, minute);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Future<String> confirmAppointment(Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection('appointments').add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save appointment to Firestore: $e');
    }
  }

  @override
  Stream<List<AppointmentModel>> getUpcomingAppointments(String uid) {
    return _watchAppointments(
      uid: uid,
      status: 'confirmed',
      ascending: true,
    );
  }

  @override
  Stream<List<AppointmentModel>> getCompletedAppointments(String uid) {
    return _watchAppointments(
      uid: uid,
      status: 'completed',
      ascending: false,
    );
  }

  @override
  Stream<List<AppointmentModel>> getCancelledAppointments(String uid) {
    return _watchAppointments(
      uid: uid,
      status: 'cancelled',
      ascending: false,
    );
  }

  Stream<List<AppointmentModel>> _watchAppointments({
    required String uid,
    required String status,
    required bool ascending,
  }) {
    final controller = StreamController<List<AppointmentModel>>.broadcast();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;
    var useOrderedQuery = true;

    void listen() {
      subscription?.cancel();

      Query<Map<String, dynamic>> query = _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: uid)
          .where('status', isEqualTo: status);

      if (useOrderedQuery) {
        query = query.orderBy('date', descending: !ascending);
      }

      subscription = query.snapshots().listen(
        (snapshot) {
          final items = snapshot.docs.map(AppointmentModel.fromFirestore).toList();
          if (!useOrderedQuery) {
            items.sort(
              (a, b) => ascending
                  ? a.appointmentDate.compareTo(b.appointmentDate)
                  : b.appointmentDate.compareTo(a.appointmentDate),
            );
          }
          controller.add(items);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (useOrderedQuery) {
            useOrderedQuery = false;
            listen();
            return;
          }
          controller.addError(error, stackTrace);
        },
      );
    }

    listen();
    controller.onCancel = () => subscription?.cancel();
    return controller.stream;
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    final trimmedId = appointmentId.trim();
    if (trimmedId.isEmpty) {
      throw Exception('Appointment id is required to cancel.');
    }

    try {
      await _firestore.collection('appointments').doc(trimmedId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }
}
