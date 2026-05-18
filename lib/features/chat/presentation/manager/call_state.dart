class CallState {
  const CallState({
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isVideoOn = false,
    this.durationSeconds = 0,
    this.callStatus = CallState.connecting,
  });

  static const String connecting = 'Connecting';
  static const String active = 'Active';
  static const String ended = 'Ended';

  final bool isMuted;
  final bool isSpeakerOn;
  final bool isVideoOn;
  final int durationSeconds;
  final String callStatus;

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  CallState copyWith({
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isVideoOn,
    int? durationSeconds,
    String? callStatus,
  }) {
    return CallState(
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isVideoOn: isVideoOn ?? this.isVideoOn,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      callStatus: callStatus ?? this.callStatus,
    );
  }
}
