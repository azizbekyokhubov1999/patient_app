import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/message_model.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    required this.message,
    required this.isMe,
    required this.peerAvatarUrl,
    required this.myAvatarUrl,
    super.key,
  });

  final MessageModel message;
  final bool isMe;
  final String peerAvatarUrl;
  final String myAvatarUrl;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _audioPlaying = false;

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isMe = widget.isMe;
    final timeLabel = DateFormat('hh:mm a').format(message.timestamp).toLowerCase();

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: message.messageType == MessageType.image
                    ? const EdgeInsets.all(6)
                    : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : AppColors.white,
                  borderRadius: borderRadius,
                  border: isMe
                      ? null
                      : Border.all(color: AppColors.neutral200),
                ),
                child: _MessageBody(
                  message: message,
                  isMe: isMe,
                  audioPlaying: _audioPlaying,
                  onToggleAudio: () =>
                      setState(() => _audioPlaying = !_audioPlaying),
                ),
              ),
              const SizedBox(height: 6),
              _MessageFooter(
                isMe: isMe,
                senderName: message.senderName,
                timeLabel: timeLabel,
                avatarUrl: isMe ? widget.myAvatarUrl : widget.peerAvatarUrl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({
    required this.message,
    required this.isMe,
    required this.audioPlaying,
    required this.onToggleAudio,
  });

  final MessageModel message;
  final bool isMe;
  final bool audioPlaying;
  final VoidCallback onToggleAudio;

  @override
  Widget build(BuildContext context) {
    switch (message.messageType) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: isMe ? AppColors.white : AppColors.primaryText,
          ),
        );
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: message.content.isNotEmpty
                ? Image.network(
                    message.content,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _ImagePlaceholder(),
                  )
                : const _ImagePlaceholder(),
          ),
        );
      case MessageType.audio:
        return _AudioBubbleContent(
          isMe: isMe,
          duration: message.duration ?? '0:00',
          playing: audioPlaying,
          onToggle: onToggleAudio,
        );
    }
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.neutral200,
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: AppColors.secondaryText.withValues(alpha: 0.45),
      ),
    );
  }
}

class _AudioBubbleContent extends StatelessWidget {
  const _AudioBubbleContent({
    required this.isMe,
    required this.duration,
    required this.playing,
    required this.onToggle,
  });

  final bool isMe;
  final String duration;
  final bool playing;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final iconColor = isMe ? AppColors.white : AppColors.primary;
    final barColor = isMe
        ? AppColors.white.withValues(alpha: 0.85)
        : AppColors.primary.withValues(alpha: 0.65);

    return SizedBox(
      width: 220,
      child: Row(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 28,
              child: CustomPaint(
                painter: _WaveformPainter(color: barColor),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            duration,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.color});

  final Color color;

  static const List<double> _heights = [
    0.35, 0.55, 0.8, 0.5, 0.9, 0.45, 0.7, 0.6, 0.85, 0.4, 0.75, 0.5, 0.65,
    0.9, 0.55, 0.7, 0.45, 0.8,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    final barWidth = size.width / (_heights.length * 2);
    for (var i = 0; i < _heights.length; i++) {
      final x = i * barWidth * 2 + barWidth / 2;
      final barHeight = size.height * _heights[i];
      final y1 = (size.height - barHeight) / 2;
      final y2 = y1 + barHeight;
      canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MessageFooter extends StatelessWidget {
  const _MessageFooter({
    required this.isMe,
    required this.senderName,
    required this.timeLabel,
    required this.avatarUrl,
  });

  final bool isMe;
  final String senderName;
  final String timeLabel;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final avatar = _SmallAvatar(url: avatarUrl);
    final nameText = Text(
      senderName,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.secondaryText,
        fontWeight: FontWeight.w500,
      ),
    );
    final timeText = Text(
      timeLabel,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.secondaryText,
      ),
    );

    if (isMe) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          timeText,
          const SizedBox(width: 8),
          nameText,
          const SizedBox(width: 6),
          avatar,
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 6),
          Flexible(child: nameText),
          const SizedBox(width: 8),
          timeText,
        ],
      ),
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  const _SmallAvatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: AppColors.neutral200,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty
          ? Icon(
              Icons.person_rounded,
              size: 14,
              color: AppColors.secondaryText.withValues(alpha: 0.5),
            )
          : null,
    );
  }
}
