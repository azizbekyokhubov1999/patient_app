import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../data/models/doctor_model.dart';
import 'favourite_doctor_card.dart';
import 'favourites_empty_view.dart';

class FavouriteDoctorsView extends StatelessWidget {
  const FavouriteDoctorsView({
    required this.doctors,
    super.key,
  });

  final List<DoctorModel> doctors;

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return const FavouritesEmptyView();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      itemCount: doctors.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        return FavouriteDoctorCard(doctor: doctors[index]);
      },
    );
  }
}
