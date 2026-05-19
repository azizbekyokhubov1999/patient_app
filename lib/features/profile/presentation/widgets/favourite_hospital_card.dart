import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../data/models/hospital_model.dart';
import '../manager/favourites_cubit.dart';

class FavouriteHospitalCard extends StatelessWidget {
  const FavouriteHospitalCard({required this.hospital, super.key});

  final HospitalModel hospital;

  String get _specialtiesLine {
    if (hospital.specialties.isNotEmpty) {
      return hospital.specialties.join(', ');
    }
    return hospital.tags;
  }

  String get _etaLine {
    final minutes = hospital.durationInMinutes > 0
        ? hospital.durationInMinutes
        : _parseLeadingInt(hospital.eta);
    final miles = hospital.distanceInMiles > 0
        ? hospital.distanceInMiles
        : _parseLeadingDouble(hospital.distance);
    return '$minutes Min • ${miles.toStringAsFixed(1)} Miles';
  }

  int _parseLeadingInt(String raw) {
    final match = RegExp(r'(\d+)').firstMatch(raw);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  double _parseLeadingDouble(String raw) {
    final match = RegExp(r'([\d.]+)').firstMatch(raw);
    return double.tryParse(match?.group(1) ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  hospital.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: AppColors.neutral200,
                    child: Icon(
                      LucideIcons.building2,
                      size: 48,
                      color: AppColors.secondaryText.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context
                          .read<FavouritesCubit>()
                          .toggleHospitalFavourite(hospital.id),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
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
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hospital.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
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
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.secondaryText,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  hospital.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
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
                              const Icon(
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
                                  style: const TextStyle(
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
                        onTap: () => MapLauncher.openDirections(
                          latitude: hospital.latitude,
                          longitude: hospital.longitude,
                          label: hospital.name,
                        ),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            LucideIcons.navigation,
                            size: 16,
                            color: AppColors.white,
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
    );
  }
}
