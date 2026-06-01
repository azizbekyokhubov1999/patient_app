import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/di/app_dependencies.dart';
import '../../../appointments/data/appointment_mock_logic.dart';
import '../../../chat/data/models/chat_model.dart';
import '../../../chat/presentation/models/call_session_args.dart';
import '../../../home/presentation/manager/get_direction_args.dart';
import '../../domain/entities/appointment_model.dart';
import '../models/consultation_ended_args.dart';
import '../models/e_receipt_args.dart';
import '../models/queue_status_args.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/doctor_review.dart';
import '../../../home/domain/entities/working_hours_entry.dart';
import '../../domain/utils/appointment_time_helper.dart';

EReceiptArgs eReceiptArgsFromAppointment(AppointmentModel appointment) {
  return EReceiptArgs(
    appointmentId: appointment.displayAppointmentId,
    patientName: appointment.patientName ?? 'Patient',
    patientPhone: appointment.patientPhone ?? '+1 (208) 555-0112',
    doctorName: appointment.doctorName,
    packageType: appointment.packageType,
    packageDuration: appointment.packageDuration,
    bookingDate: appointment.appointmentDate,
    bookingTime: appointment.startTime,
    subTotal: appointment.subTotal,
    discount: appointment.discount,
    totalAmount: appointment.totalAmount,
    hospitalKioskFlow: appointment.type == 'offline',
    queueStatusAfterScan: QueueStatusArgs(
      appointmentId: appointment.displayAppointmentId,
    ),
  );
}

GetDirectionArgs getDirectionArgsFromAppointment(AppointmentModel appointment) {
  final direction = AppointmentMockLogic.directionArgsFor(appointment);
  return GetDirectionArgs(
    hospitalId: direction.hospitalId,
    hospitalName: direction.hospitalName,
    geoPoint: direction.geoPoint,
    hospitalAddress: direction.hospitalAddress,
    eReceipt: eReceiptArgsFromAppointment(appointment),
  );
}

Doctor doctorFromAppointment(AppointmentModel appointment) {
  return Doctor(
    id: appointment.doctorId ?? appointment.documentId,
    name: appointment.doctorName,
    specialty: appointment.doctorSpecialty,
    rating: appointment.doctorRating,
    reviewsCount: 0,
    imageUrl: appointment.doctorImageUrl ?? '',
    about: '',
    patientsCount: 0,
    experienceYears: 0,
    workingHours: const [
      WorkingHoursEntry('Monday - Friday', '09:00 am - 06:00 pm'),
    ],
    address: appointment.hospitalAddress,
    latitude: 0,
    longitude: 0,
    patientReviews: const <DoctorReview>[],
  );
}

ConsultationEndedArgs consultationEndedArgsFromAppointment(
  AppointmentModel appointment,
) {
  return ConsultationEndedArgs(
    appointmentId: appointment.displayAppointmentId,
    doctor: doctorFromAppointment(appointment),
    documentId: appointment.documentId,
  );
}

Future<void> navigateJoinSession(
  BuildContext context,
  AppointmentModel appointment,
) async {
  final kind = normalizePackageType(appointment.packageType);

  switch (kind) {
    case 'messaging':
      await _openChatForAppointment(context, appointment);
    case 'videocall':
      await context.push(
        AppPaths.videoCall,
        extra: CallSessionArgs(
          appointmentId: appointment.displayAppointmentId,
          doctorId: appointment.doctorId ?? appointment.documentId,
          doctorName: appointment.doctorName,
          doctorSpecialty: appointment.doctorSpecialty,
          doctorAvatar: appointment.doctorImageUrl ?? '',
          initialVideoOn: true,
        ),
      );
    case 'voicecall':
      await context.push(
        AppPaths.voiceCall,
        extra: CallSessionArgs(
          appointmentId: appointment.displayAppointmentId,
          doctorId: appointment.doctorId ?? appointment.documentId,
          doctorName: appointment.doctorName,
          doctorSpecialty: appointment.doctorSpecialty,
          doctorAvatar: appointment.doctorImageUrl ?? '',
          initialVideoOn: false,
        ),
      );
    default:
      break;
  }
}

Future<void> _openChatForAppointment(
  BuildContext context,
  AppointmentModel appointment,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || !context.mounted) return;

  final doctorId = appointment.doctorId?.trim() ?? '';
  if (doctorId.isEmpty) return;

  var patientName = appointment.patientName?.trim() ?? '';
  var patientImage = '';
  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = userDoc.data() ?? {};
    patientName = patientName.isNotEmpty
        ? patientName
        : (data['name'] as String? ??
            data['displayName'] as String? ??
            user.displayName ??
            'Patient');
    patientImage = data['photoUrl'] as String? ?? '';
  } catch (_) {
    patientName = patientName.isNotEmpty
        ? patientName
        : (user.displayName ?? 'Patient');
  }

  final chatId = await AppDependencies.instance.chatRepository.createChat(
    patientId: user.uid,
    doctorId: doctorId,
    doctorName: appointment.doctorName,
    doctorImage: appointment.doctorImageUrl ?? '',
    doctorSpecialty: appointment.doctorSpecialty,
    patientName: patientName,
    patientImage: patientImage,
    appointmentId: appointment.documentId,
  );

  if (!context.mounted) return;

  await context.push(
    AppPaths.chatDetail,
    extra: ChatModel(
      id: chatId,
      patientId: user.uid,
      doctorId: doctorId,
      doctorName: appointment.doctorName,
      doctorImage: appointment.doctorImageUrl ?? '',
      doctorSpecialty: appointment.doctorSpecialty,
      patientName: patientName,
      patientImage: patientImage,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      appointmentId: appointment.documentId,
      createdAt: DateTime.now(),
      isOnline: true,
    ),
  );
}

void navigateGetDirection(BuildContext context, AppointmentModel appointment) {
  context.push(
    AppPaths.getDirection,
    extra: getDirectionArgsFromAppointment(appointment),
  );
}

void navigateScanQr(BuildContext context, AppointmentModel appointment) {
  context.push(
    AppPaths.appointmentEReceipt,
    extra: eReceiptArgsFromAppointment(appointment)
        .copyWith(hospitalKioskFlow: true),
  );
}

void navigateConsultationEnded(
  BuildContext context,
  AppointmentModel appointment,
) {
  context.push(
    AppPaths.appointmentConsultationEnded,
    extra: consultationEndedArgsFromAppointment(appointment),
  );
}
