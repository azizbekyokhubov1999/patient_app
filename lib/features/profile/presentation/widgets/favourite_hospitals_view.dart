import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../data/models/hospital_model.dart';
import 'favourite_hospital_card.dart';
import 'favourites_empty_view.dart';

class FavouriteHospitalsView extends StatelessWidget {
  const FavouriteHospitalsView({
    required this.hospitals,
    super.key,
  });

  final List<HospitalModel> hospitals;

  @override
  Widget build(BuildContext context) {
    if (hospitals.isEmpty) {
      return const FavouritesEmptyView();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      itemCount: hospitals.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        return FavouriteHospitalCard(hospital: hospitals[index]);
      },
    );
  }
}
