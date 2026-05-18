import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/chat_model.dart';

/// Single conversation row card in the chat list.
class ChatTile extends StatelessWidget {
  const ChatTile({
    required this.chat,
    this.onTap,
    super.key,
  });

  final ChatModel chat;
  final VoidCallback? onTap;

  static const Color _onlineGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasUnread = chat.unreadCount > 0;
    final timeLabel = DateFormat('hh:mm a').format(chat.lastMessageTime);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.neutral200,
                    backgroundImage: chat.doctorAvatar.isNotEmpty
                        ? NetworkImage(chat.doctorAvatar)
                        : null,
                    child: chat.doctorAvatar.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            color: AppColors.secondaryText.withValues(alpha: 0.5),
                          )
                        : null,
                  ),
                  if (chat.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _onlineGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.doctorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: hasUnread
                            ? AppColors.primary
                            : AppColors.secondaryText,
                        fontWeight:
                            hasUnread ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeLabel,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (hasUnread)
                    Container(
                      constraints: const BoxConstraints(minWidth: 22),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${chat.unreadCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    )
                  else if (chat.isReadBySub)
                    const Icon(
                      Icons.done_all,
                      size: 18,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
