import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/appointment_model.dart';

class UpcomingAppointmentCard extends StatefulWidget {
  const UpcomingAppointmentCard({
    required this.appointment,
    required this.onCancel,
    required this.onViewReceipt,
    required this.onToggleReminder,
    required this.onDoctorTap,
    this.onJoinSession,
    this.onGetDirection,
    this.onScanQr,
    this.onSimulateDoctorComplete,
    super.key,
  });

  final AppointmentModel appointment;
  final VoidCallback onCancel;
  final VoidCallback onViewReceipt;
  final ValueChanged<bool> onToggleReminder;
  final VoidCallback onDoctorTap;
  final VoidCallback? onJoinSession;
  final VoidCallback? onGetDirection;
  final VoidCallback? onScanQr;
  final VoidCallback? onSimulateDoctorComplete;

  @override
  State<UpcomingAppointmentCard> createState() => _UpcomingAppointmentCardState();
}

class _UpcomingAppointmentCardState extends State<UpcomingAppointmentCard> {
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _UpcomingAppointmentCardBody(
      appointment: widget.appointment,
      onCancel: widget.onCancel,
      onViewReceipt: widget.onViewReceipt,
      onToggleReminder: widget.onToggleReminder,
      onDoctorTap: widget.onDoctorTap,
      onJoinSession: widget.onJoinSession,
      onGetDirection: widget.onGetDirection,
      onScanQr: widget.onScanQr,
      onSimulateDoctorComplete: widget.onSimulateDoctorComplete,
    );
  }
}

class _UpcomingAppointmentCardBody extends StatelessWidget {
  const _UpcomingAppointmentCardBody({
    required this.appointment,
    required this.onCancel,
    required this.onViewReceipt,
    required this.onToggleReminder,
    required this.onDoctorTap,
    this.onJoinSession,
    this.onGetDirection,
    this.onScanQr,
    this.onSimulateDoctorComplete,
  });

  final AppointmentModel appointment;
  final VoidCallback onCancel;
  final VoidCallback onViewReceipt;
  final ValueChanged<bool> onToggleReminder;
  final VoidCallback onDoctorTap;
  final VoidCallback? onJoinSession;
  final VoidCallback? onGetDirection;
  final VoidCallback? onScanQr;
  final VoidCallback? onSimulateDoctorComplete;

  static const Color _badgeBg = Color(0xFFFFF4E5);
  static const Color _badgeText = Color(0xFFE67E22);
  static const Color _chipBg = Color(0xFFE8F0FF);
  static const Color _cancelBg = Color(0xFFF3F4F6);
  static const Color _cancelText = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final showJoin = appointment.showJoinSession;
    final showDirection = appointment.showGetDirection;
    final showScan = appointment.showScanQR;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.grey.withValues(alpha: 0.12),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Upcoming Appointments',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _badgeText,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Remind me',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 6),
                Switch.adaptive(
                  value: appointment.remindEnabled,
                  activeTrackColor: AppColors.primary,
                  activeThumbColor: AppColors.white,
                  onChanged: onToggleReminder,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.stroke),
            const SizedBox(height: 14),
            InkWell(
              onTap: onDoctorTap,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: _DoctorAvatar(imageUrl: appointment.doctorImageUrl),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _chipBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            appointment.doctorSpecialty,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appointment.doctorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: i < appointment.doctorRating.round()
                                    ? Colors.amber
                                    : AppColors.neutral200,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              appointment.doctorRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetaColumn(
                    label: 'Appointment ID',
                    value: appointment.displayAppointmentId,
                    valueBold: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetaColumn(
                    label: 'Booking Date & Time',
                    value: appointment.bookingDateTimeLabel,
                  ),
                ),
              ],
            ),
            if (showJoin || showDirection || showScan) ...[
              const SizedBox(height: 16),
              if (showJoin)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onJoinSession,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Join or Start Session',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (showDirection) ...[
                if (showJoin) const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onGetDirection,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Get Direction',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              if (showScan) ...[
                if (showJoin || showDirection) const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onScanQr,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Scan QR',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              if (showJoin && onSimulateDoctorComplete != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onSimulateDoctorComplete,
                  child: const Text(
                    'Demo: Simulate doctor completing session',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      backgroundColor: _cancelBg,
                      foregroundColor: _cancelText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onViewReceipt,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View E-Receipt',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaColumn extends StatelessWidget {
  const _MetaColumn({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  final String label;
  final String value;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.doctorMeta.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: valueBold
              ? AppTextStyles.titleMedium.copyWith(fontSize: 15)
              : AppTextStyles.doctorMeta.copyWith(
                  fontSize: 13,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                ),
        ),
      ],
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const _AvatarFallback(),
      );
    }
    return const _AvatarFallback();
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.neutral200,
      child: Icon(
        Icons.person_rounded,
        size: 36,
        color: AppColors.secondaryText.withValues(alpha: 0.5),
      ),
    );
  }
}
