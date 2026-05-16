import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NotificationGroupHeader extends StatelessWidget {
  const NotificationGroupHeader({
    required this.groupLabel,
    required this.onMarkAllRead,
    super.key,
  });

  final String groupLabel;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            groupLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
          ),
          TextButton(
            onPressed: onMarkAllRead,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Mark all as read',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
