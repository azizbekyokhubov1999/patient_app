import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../models/queue_status_args.dart';

/// Waiting room status after a successful hospital QR scan.
class QueueStatusPage extends StatelessWidget {
  const QueueStatusPage({required this.args, super.key});

  final QueueStatusArgs args;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: 'Queue Status',
        backgroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F0FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'You are in the queue',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please wait until your number is called.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.doctorMeta.copyWith(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _StatusTile(
                    icon: Icons.meeting_room_outlined,
                    label: 'Room No',
                    value: args.roomNumber,
                  ),
                  const SizedBox(height: 16),
                  _StatusTile(
                    icon: Icons.format_list_numbered_rounded,
                    label: 'Queue Number',
                    value: '#${args.queueNumber}',
                  ),
                  const SizedBox(height: 16),
                  _StatusTile(
                    icon: Icons.schedule_rounded,
                    label: 'Estimated Waiting Time',
                    value: args.estimatedWait,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(AppPaths.home),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back to Home',
                    style: AppTextStyles.buttonLabel,
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

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.doctorMeta.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 17),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
