import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/chat_model.dart';

/// Horizontal list item for online doctors on the Chat header.
class ActiveDoctorAvatar extends StatelessWidget {
  const ActiveDoctorAvatar({
    required this.doctor,
    this.onTap,
    super.key,
  });

  final ChatModel doctor;
  final VoidCallback? onTap;

  static const Color _onlineGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: _AvatarImage(url: doctor.doctorAvatar),
                  ),
                ),
                if (doctor.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _onlineGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              doctor.firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const _AvatarFallback();
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _AvatarFallback(),
    );
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
        color: AppColors.secondaryText.withValues(alpha: 0.5),
        size: 28,
      ),
    );
  }
}
