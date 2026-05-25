import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../booking/presentation/utils/booking_navigation.dart';
import '../../../booking/presentation/widgets/verified_doctor_avatar.dart';
import '../../data/models/doctor_model.dart';
import '../manager/favourites_cubit.dart';

class FavouriteDoctorCard extends StatelessWidget {
  const FavouriteDoctorCard({required this.doctor, super.key});

  final DoctorModel doctor;

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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 76,
                child: VerifiedDoctorAvatar(
                  imageUrl: doctor.imageUrl,
                  radius: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _RatingRow(
                      rating: doctor.rating,
                      reviewsCount: doctor.reviewsCount,
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final id = doctor.documentId;
                    if (id.isNotEmpty) {
                      context
                          .read<FavouritesCubit>()
                          .toggleDoctorFavourite(id);
                    }
                  },
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: () => BookingNavigation.startBooking(
              context,
              doctor: doctor,
              doctorId: doctor.id,
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Make Appointment',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.rating,
    required this.reviewsCount,
  });

  final double rating;
  final int reviewsCount;

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor().clamp(0, 5);

    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < fullStars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 15,
            color: AppColors.warning,
          );
        }),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${rating.toStringAsFixed(1)} | $reviewsCount Reviews',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
