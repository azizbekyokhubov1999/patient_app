import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
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
  switch (appointment.type) {
    case 'video':
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
    case 'voice':
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
    case 'messaging':
      await context.push(
        AppPaths.chatDetail,
        extra: ChatModel(
          chatId: 'chat-${appointment.documentId}',
          doctorId: appointment.doctorId ?? appointment.documentId,
          doctorName: appointment.doctorName,
          doctorAvatar: appointment.doctorImageUrl ?? '',
          lastMessage: 'Session ready — tap to open chat',
          lastMessageTime: DateTime.now(),
          unreadCount: 0,
          isReadBySub: true,
          isOnline: true,
        ),
      );
    default:
      break;
  }
}

void navigateGetDirection(BuildContext context, AppointmentModel appointment) {
  context.push(
    AppPaths.appointmentGetDirection,
    extra: getDirectionArgsFromAppointment(appointment),
  );
}

void navigateScanQr(BuildContext context, AppointmentModel appointment) {
  context.push(
    AppPaths.appointmentEReceipt,
    extra: eReceiptArgsFromAppointment(appointment),
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
