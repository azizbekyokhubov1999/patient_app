import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/package_type.dart';

class PackageCard extends StatelessWidget {
  const PackageCard({
    required this.package,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final PackageType package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconFor(package),
                size: 24,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 38),
                  Text(
                    _titleFor(package),
                    style: AppTextStyles.doctorName.copyWith(fontSize: 32 / 2, height: 1.1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _descriptionFor(package),
                    style: AppTextStyles.doctorMeta.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.outline,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  _priceFor(package),
                  style: AppTextStyles.doctorName.copyWith(fontSize: 32 / 2, height: 1.1),
                ),
                const SizedBox(height: 4),
                Text(
                  '/30 mins',
                  style: AppTextStyles.doctorMeta.copyWith(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(PackageType package) {
  switch (package) {
    case PackageType.messaging:
      return LucideIcons.messageCircle;
    case PackageType.voiceCall:
      return LucideIcons.phone;
    case PackageType.videoCall:
      return LucideIcons.video;
    case PackageType.inPerson:
      return LucideIcons.house;
  }
}

String _titleFor(PackageType package) {
  switch (package) {
    case PackageType.messaging:
      return 'Messaging';
    case PackageType.voiceCall:
      return 'Voice Call';
    case PackageType.videoCall:
      return 'Video Call';
    case PackageType.inPerson:
      return 'In Person';
  }
}

String _descriptionFor(PackageType package) {
  switch (package) {
    case PackageType.messaging:
      return 'Chat with Doctor';
    case PackageType.voiceCall:
      return 'Voice call with doctor';
    case PackageType.videoCall:
      return 'Video call with doctor';
    case PackageType.inPerson:
      return 'In Person visit with doctor';
  }
}

String _priceFor(PackageType package) {
  switch (package) {
    case PackageType.messaging:
      return '\$20';
    case PackageType.voiceCall:
      return '\$40';
    case PackageType.videoCall:
      return '\$60';
    case PackageType.inPerson:
      return '\$100';
  }
}
