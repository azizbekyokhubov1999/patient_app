import '../../data/models/chat_model.dart';

/// Navigation payload for voice / video call screens.
class CallSessionArgs {
  const CallSessionArgs({
    required this.appointmentId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorAvatar,
    this.initialVideoOn = false,
    this.initialDurationSeconds = 0,
    this.initialMuted = false,
    this.initialSpeakerOn = false,
  });

  final String appointmentId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorAvatar;
  final bool initialVideoOn;
  final int initialDurationSeconds;
  final bool initialMuted;
  final bool initialSpeakerOn;

  factory CallSessionArgs.fromChat(ChatModel chat, {bool video = false}) {
    return CallSessionArgs(
      appointmentId: chat.chatId,
      doctorId: chat.doctorId,
      doctorName: chat.doctorName,
      doctorSpecialty: 'Dentist',
      doctorAvatar: chat.doctorAvatar,
      initialVideoOn: video,
    );
  }

  CallSessionArgs copyWithSessionState({
    required bool isVideoOn,
    required int durationSeconds,
    required bool isMuted,
    required bool isSpeakerOn,
  }) {
    return CallSessionArgs(
      appointmentId: appointmentId,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      doctorAvatar: doctorAvatar,
      initialVideoOn: isVideoOn,
      initialDurationSeconds: durationSeconds,
      initialMuted: isMuted,
      initialSpeakerOn: isSpeakerOn,
    );
  }
}
