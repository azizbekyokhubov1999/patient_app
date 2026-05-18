import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CallControlBar extends StatelessWidget {
  const CallControlBar({
    required this.isMuted,
    required this.isSpeakerOn,
    required this.isVideoOn,
    required this.onToggleMute,
    required this.onToggleSpeaker,
    required this.onToggleVideo,
    required this.onOpenChat,
    required this.onEndCall,
    super.key,
  });

  final bool isMuted;
  final bool isSpeakerOn;
  final bool isVideoOn;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleVideo;
  final VoidCallback onOpenChat;
  final VoidCallback onEndCall;

  static const Color _endCallRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: 132 + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipPath(
              clipper: CallBarClipper(),
              child: Container(
                height: 88 + bottomInset,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: bottomInset + 12,
                  top: 38,
                ),
                color: AppColors.primary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CallBarIconButton(
                      icon: isSpeakerOn
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      onTap: onToggleSpeaker,
                    ),
                    _CallBarIconButton(
                      icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      onTap: onToggleMute,
                    ),
                    const SizedBox(width: 72),
                    _CallBarIconButton(
                      icon: isVideoOn
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      onTap: onToggleVideo,
                    ),
                    _CallBarIconButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      onTap: onOpenChat,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50 + bottomInset,
            child: Material(
              color: _endCallRed,
              shape: const CircleBorder(),
              elevation: 6,
              shadowColor: _endCallRed.withValues(alpha: 0.45),
              child: InkWell(
                onTap: onEndCall,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 64,
                  height: 64,
                  child: Icon(
                    Icons.call_end_rounded,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallBarIconButton extends StatelessWidget {
  const _CallBarIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.white, size: 22),
      ),
    );
  }
}

/// Top edge of the control bar with a smooth center concave dip.
class CallBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const dipHalfWidth = 60.0;
    const dipDepth = 50.0;
    final centerX = size.width / 2;
    final leftDip = centerX - dipHalfWidth;
    final rightDip = centerX + dipHalfWidth;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(leftDip, 0)
      ..cubicTo(
        leftDip + 18,
        0,
        centerX - 14,
        dipDepth,
        centerX,
        dipDepth,
      )
      ..cubicTo(
        centerX + 14,
        dipDepth,
        rightDip - 18,
        0,
        rightDip,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CallBarClipper oldClipper) => false;
}
