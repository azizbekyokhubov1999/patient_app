import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/appointment_preview.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  const UpcomingAppointmentCard({
    required this.appointment,
    required this.onTap,
    super.key,
  });

  final AppointmentPreview appointment;
  final VoidCallback onTap;

  static const Color _upperBg = Color(0xFFF5F5F5);
  static const Color _nameColor = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('EEEE, d MMMM').format(appointment.appointmentDate);

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.grey.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: AppColors.white,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: _upperBg),
                      Positioned(
                        left: -16,
                        top: 0,
                        bottom: 0,
                        width: 130,
                        child: Opacity(
                          opacity: 0.18,
                          child: appointment.doctorImageUrl != null &&
                                  appointment.doctorImageUrl!.isNotEmpty
                              ? Image.network(
                                  appointment.doctorImageUrl!,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.centerLeft,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    LucideIcons.globe,
                                    size: 96,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  LucideIcons.globe,
                                  size: 96,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(72, 12, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                appointment.doctorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _nameColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appointment.doctorSpecialty,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    appointment.doctorRating.toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _nameColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 48,
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.calendarDays,
                        size: 16,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Text(
                          dateLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Center(
                          child: Container(
                            width: 1,
                            height: 20,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      Icon(
                        LucideIcons.clock,
                        size: 16,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${appointment.startTime} - ${appointment.endTime}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
