import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'call_state.dart';

class CallCubit extends Cubit<CallState> {
  CallCubit({
    bool initialVideoOn = false,
    int initialDurationSeconds = 0,
    bool initialMuted = false,
    bool initialSpeakerOn = false,
  }) : super(
          CallState(
            isVideoOn: initialVideoOn,
            durationSeconds: initialDurationSeconds,
            isMuted: initialMuted,
            isSpeakerOn: initialSpeakerOn,
            callStatus: CallState.connecting,
          ),
        ) {
    _connect();
  }

  Timer? _timer;

  Future<void> _connect() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (isClosed) return;
    emit(state.copyWith(callStatus: CallState.active));
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.callStatus != CallState.active) return;
      emit(state.copyWith(durationSeconds: state.durationSeconds + 1));
    });
  }

  void toggleMute() {
    emit(state.copyWith(isMuted: !state.isMuted));
  }

  void toggleSpeaker() {
    emit(state.copyWith(isSpeakerOn: !state.isSpeakerOn));
  }

  void toggleVideo() {
    emit(state.copyWith(isVideoOn: !state.isVideoOn));
  }

  void endCall() {
    _timer?.cancel();
    emit(state.copyWith(callStatus: CallState.ended));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
