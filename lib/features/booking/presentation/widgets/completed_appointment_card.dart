import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/appointment_model.dart';

class CompletedAppointmentCard extends StatelessWidget {
  const CompletedAppointmentCard({
    required this.appointment,
    required this.onLeaveReview,
    required this.onViewReceipt,
    required this.onDoctorTap,
    super.key,
  });

  final AppointmentModel appointment;
  final VoidCallback onLeaveReview;
  final VoidCallback onViewReceipt;
  final VoidCallback onDoctorTap;

  static const Color _badgeBg = Color(0xFFE8F5E9);
  static const Color _badgeText = Color(0xFF2E7D32);
  static const Color _chipBg = Color(0xFFE8F0FF);
  static const Color _reviewBg = Color(0xFFF0F4FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.grey.withValues(alpha: 0.1),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Appointments Completed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _badgeText,
                ),
              ),
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
            _DetailRow(
              label: 'Appointment ID',
              value: appointment.displayAppointmentId,
              valueBold: true,
            ),
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Booking Date & Time',
              value: appointment.bookingDateTimeLabel,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onLeaveReview,
                    style: TextButton.styleFrom(
                      backgroundColor: _reviewBg,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Leave Review',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  final String label;
  final String value;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.doctorMeta.copyWith(fontSize: 12),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
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
