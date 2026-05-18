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

class VoiceCallPage extends StatelessWidget {
  const VoiceCallPage({required this.args, super.key});

  final CallSessionArgs args;

  @override
  Widget build(BuildContext context) {
    return CallSessionListener(
      args: args,
      isVideoRoute: false,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _CallBackground(avatarUrl: args.doctorAvatar),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _TranslucentBackButton(
                        onTap: () => context.pop(),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _VoiceCallCenter(args: args),
                  const Spacer(),
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

class _VoiceCallCenter extends StatelessWidget {
  const _VoiceCallCenter({required this.args});

  final CallSessionArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallCubit, CallState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3),
              ),
              child: CircleAvatar(
                radius: 72,
                backgroundColor: AppColors.neutral700,
                backgroundImage: args.doctorAvatar.isNotEmpty
                    ? NetworkImage(args.doctorAvatar)
                    : null,
                child: args.doctorAvatar.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        size: 64,
                        color: AppColors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              args.doctorName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              args.doctorSpecialty,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.white.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 20),
            CallDurationChip(durationLabel: state.formattedDuration),
            if (state.callStatus == CallState.connecting) ...[
              const SizedBox(height: 16),
              Text(
                'Connecting…',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CallBackground extends StatelessWidget {
  const _CallBackground({required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (avatarUrl.isNotEmpty)
          Image.network(
            avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF2A2D35)),
          )
        else
          const ColoredBox(color: Color(0xFF2A2D35)),
        Container(
          color: Colors.black.withValues(alpha: 0.55),
        ),
      ],
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
          color: Colors.white.withValues(alpha: 0.2),
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
