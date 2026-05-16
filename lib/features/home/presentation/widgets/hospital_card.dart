import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/hospital.dart';

class HospitalCard extends StatelessWidget {
  const HospitalCard({
    required this.hospital,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onDirectionTap,
    super.key,
  });

  final Hospital hospital;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDirectionTap;

  static const Color _titleColor = Color(0xFF1A1A2E);

  String get _specialtiesLine {
    if (hospital.specialties.isNotEmpty) {
      return hospital.specialties.join(', ');
    }
    return hospital.tags;
  }

  int get _durationMinutes {
    if (hospital.durationInMinutes > 0) return hospital.durationInMinutes;
    final match = RegExp(r'(\d+)').firstMatch(hospital.eta);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  double get _distanceMilesLine {
    if (hospital.distanceInMiles > 0) return hospital.distanceInMiles;
    final match = RegExp(r'([\d.]+)').firstMatch(hospital.distance);
    return double.tryParse(match?.group(1) ?? '') ?? 0;
  }

  String get _etaLine =>
      '$_durationMinutes Min • ${_distanceMilesLine.toStringAsFixed(1)} Miles';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 1,
            color: Colors.grey.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 180,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        hospital.imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return ColoredBox(
                            color: AppColors.stroke,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => ColoredBox(
                          color: AppColors.stroke,
                          child: Icon(
                            LucideIcons.building2,
                            size: 56,
                            color: AppColors.secondaryText.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.white,
                          elevation: 2,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: onFavoriteToggle,
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: Icon(
                                hospital.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                                color: hospital.isFavorite
                                    ? Colors.red
                                    : AppColors.secondaryText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              hospital.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _titleColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hospital.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _titleColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _specialtiesLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const Divider(
                        height: 24,
                        thickness: 1,
                        color: AppColors.outline,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: AppColors.secondaryText,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        hospital.address,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: AppColors.secondaryText,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _etaLine,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Material(
                            color: AppColors.primary,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: onDirectionTap,
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: Icon(
                                  LucideIcons.navigation,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
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
        ),
      ),
    );
  }
}
