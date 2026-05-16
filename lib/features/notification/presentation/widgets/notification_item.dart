import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/notification_model.dart';
import '../../domain/entities/notification_type.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  static const Color _unreadBg = Color(0xFFFFFFFF);
  static const Color _readBg = Color(0xFFFAFAFA);
  static const Color _avatarBg = Color(0xFFF5F5F5);

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.appointmentConfirmed:
        return LucideIcons.calendarCheck;
      case NotificationType.videoCallAppointment:
        return LucideIcons.video;
      case NotificationType.ratingRequested:
        return LucideIcons.star;
      case NotificationType.appointmentReminder:
        return LucideIcons.bell;
      case NotificationType.paymentMethodAdded:
        return LucideIcons.wallet;
      case NotificationType.scheduleReminder:
        return LucideIcons.clock;
      case NotificationType.systemUpdate:
        return LucideIcons.info;
    }
  }

  String _timeLabel() {
    final createdAt = notification.createdAt;
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.isNegative || diff.inMinutes < 1) return 'now';
    if (diff.inHours < 24) {
      final h = diff.inHours < 1 ? 1 : diff.inHours;
      return '${h}h';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays < 1 ? 1 : diff.inDays;
      return '${d}d';
    }
    return DateFormat.MMMd().format(createdAt);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isRead = notification.isRead;

    return Material(
      color: isRead ? _readBg : _unreadBg,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: _avatarBg,
                child: Icon(
                  _iconForType(notification.type),
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _timeLabel(),
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
