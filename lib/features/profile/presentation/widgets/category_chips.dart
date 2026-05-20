import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/help_center_model.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: HelpCategories.chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = HelpCategories.chips[index];
          final selected = category == selectedCategory;

          return FilterChip(
            label: Text(category),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => onCategorySelected(category),
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.primaryText,
            ),
            backgroundColor: AppColors.neutral100,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.stroke,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }
}
