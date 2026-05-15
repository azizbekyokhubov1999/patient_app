import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

const Color _kChipUnselectedBackground = Color(0xFFF5F5F5);

class FilterChips extends StatelessWidget {
  const FilterChips({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == selected;
          return FilterChip(
            label: Text(option),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(option),
            labelStyle: AppTextStyles.doctorMeta.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.primaryText,
            ),
            backgroundColor: _kChipUnselectedBackground,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.outline,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          );
        },
      ),
    );
  }
}
