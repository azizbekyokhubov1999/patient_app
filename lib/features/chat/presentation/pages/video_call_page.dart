import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../manager/call_cubit.dart';
import '../manager/call_state.dart';
import '../models/call_session_args.dart';
import '../widgets/call_control_bar.dart';
import '../widgets/call_duration_chip.dart';
import '../widgets/call_session_listener.dart';

class VideoCallPage extends StatelessWidget {
  const VideoCallPage({required this.args, super.key});

  final CallSessionArgs args;

  static const String _patientPreviewUrl =
      'https://picsum.photos/200?patient-preview';

  @override
  Widget build(BuildContext context) {
    return CallSessionListener(
      args: args,
      isVideoRoute: true,
      child: Scaffold(
        backgroundColor: const Color(0xFF3D3D3D),
        body: Stack(
          fit: StackFit.expand,
          children: [
            _RemoteVideoLayer(avatarUrl: args.doctorAvatar),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 12,
                    child: _TranslucentBackButton(
                      onTap: () => context.pop(),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 16,
                    child: _LocalPreviewPiP(imageUrl: _patientPreviewUrl),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 130,
                    child: BlocBuilder<CallCubit, CallState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              args.doctorName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                    fontSize: 20,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              args.doctorSpecialty,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 10),
                            CallDurationChip(
                              durationLabel: state.formattedDuration,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BlocBuilder<CallCubit, CallState>(
                builder: (context, state) {
                  return CallControlBar(
                    isMuted: state.isMuted,
                    isSpeakerOn: state.isSpeakerOn,
                    isVideoOn: state.isVideoOn,
                    onToggleMute: context.read<CallCubit>().toggleMute,
                    onToggleSpeaker: context.read<CallCubit>().toggleSpeaker,
                    onToggleVideo: context.read<CallCubit>().toggleVideo,
                    onOpenChat: () => openChatFromCall(context, args),
                    onEndCall: context.read<CallCubit>().endCall,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoteVideoLayer extends StatelessWidget {
  const _RemoteVideoLayer({required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isEmpty) {
      return const ColoredBox(color: Color(0xFF4A4A4A));
    }

    return Image.network(
      avatarUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF4A4A4A)),
    );
  }
}

class _LocalPreviewPiP extends StatelessWidget {
  const _LocalPreviewPiP({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white, width: 2),
        color: AppColors.neutral700,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(
          color: AppColors.neutral600,
          child: Icon(Icons.person_rounded, color: AppColors.white, size: 40),
        ),
      ),
    );
  }
}

class _TranslucentBackButton extends StatelessWidget {
  const _TranslucentBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.white,
          size: 20,
        ),
      ),
    );
  }
}
