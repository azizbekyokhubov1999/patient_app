import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../booking/presentation/models/consultation_ended_args.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/doctor_review.dart';
import '../../../home/domain/entities/working_hours_entry.dart';
import '../../data/models/chat_model.dart';
import '../manager/call_cubit.dart';
import '../manager/call_state.dart';
import '../models/call_session_args.dart';

/// Shared navigation reactions for voice / video call screens.
class CallSessionListener extends StatelessWidget {
  const CallSessionListener({
    required this.args,
    required this.isVideoRoute,
    required this.child,
    super.key,
  });

  final CallSessionArgs args;
  final bool isVideoRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallCubit, CallState>(
      listenWhen: (previous, current) =>
          previous.isVideoOn != current.isVideoOn ||
          previous.callStatus != current.callStatus,
      listener: (context, state) {
        if (state.callStatus == CallState.ended) {
          final doctor = _doctorFromArgs(args);
          context.go(
            AppPaths.consultationEnded,
            extra: ConsultationEndedArgs(
              appointmentId: args.appointmentId,
              doctor: doctor,
            ),
          );
          return;
        }

        if (state.isVideoOn && !isVideoRoute) {
          context.pushReplacement(
            AppPaths.videoCall,
            extra: args.copyWithSessionState(
              isVideoOn: true,
              durationSeconds: state.durationSeconds,
              isMuted: state.isMuted,
              isSpeakerOn: state.isSpeakerOn,
            ),
          );
          return;
        }

        if (!state.isVideoOn && isVideoRoute) {
          context.pushReplacement(
            AppPaths.voiceCall,
            extra: args.copyWithSessionState(
              isVideoOn: false,
              durationSeconds: state.durationSeconds,
              isMuted: state.isMuted,
              isSpeakerOn: state.isSpeakerOn,
            ),
          );
        }
      },
      child: child,
    );
  }

  Doctor _doctorFromArgs(CallSessionArgs args) {
    return Doctor(
      id: args.doctorId,
      name: args.doctorName,
      specialty: args.doctorSpecialty,
      rating: 4.9,
      reviewsCount: 0,
      imageUrl: args.doctorAvatar,
      about: '',
      patientsCount: 0,
      experienceYears: 0,
      workingHours: const [
        WorkingHoursEntry('Monday - Friday', '09:00 am - 06:00 pm'),
      ],
      address: '',
      latitude: 0,
      longitude: 0,
      patientReviews: const <DoctorReview>[],
    );
  }
}

/// Opens chat detail from an active call.
void openChatFromCall(BuildContext context, CallSessionArgs args) {
  context.push(
    AppPaths.chatDetail,
    extra: ChatModel(
      id: args.appointmentId,
      patientId: '',
      doctorId: args.doctorId,
      doctorName: args.doctorName,
      doctorImage: args.doctorAvatar,
      doctorSpecialty: args.doctorSpecialty,
      patientName: '',
      patientImage: '',
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      appointmentId: args.appointmentId,
      createdAt: DateTime.now(),
      isOnline: true,
    ),
  );
}
