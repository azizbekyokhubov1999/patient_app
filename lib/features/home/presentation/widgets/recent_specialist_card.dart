import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/doctor.dart';

class RecentSpecialistCard extends StatelessWidget {
  const RecentSpecialistCard({
    required this.doctor,
    required this.onTap,
    this.width = 140,
    super.key,
  });

  final Doctor doctor;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final url = doctor.imageUrl.trim();

    final card = Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.neutral200,
                  backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
                  child: url.isEmpty
                      ? const Icon(Icons.person_rounded, color: AppColors.secondaryText, size: 32)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  doctor.name,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  doctor.specialty,
                  style: AppTextStyles.doctorMeta.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.star,
                      size: 14,
                      color: AppColors.warning,
                      fill: 1,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating.toStringAsFixed(1),
                      style: AppTextStyles.doctorMeta.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

    if (width.isFinite) {
      return SizedBox(width: width, child: card);
    }
    return card;
  }
}
