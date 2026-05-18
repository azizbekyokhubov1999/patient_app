import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CallDurationChip extends StatelessWidget {
  const CallDurationChip({required this.durationLabel, super.key});

  final String durationLabel;

  static const Color _recordingRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _recordingRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            durationLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
