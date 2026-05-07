import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    height: 1.1,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 34 / 2,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
  );

  static const TextStyle doctorName = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
  );

  static const TextStyle doctorMeta = TextStyle(
    fontSize: 18,
    color: AppColors.secondaryText,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
}
