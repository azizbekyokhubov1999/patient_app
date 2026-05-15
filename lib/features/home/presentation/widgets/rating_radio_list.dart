import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RatingRadioList extends StatelessWidget {
  const RatingRadioList({
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
    return Column(
      children: options
          .map(
            (option) => InkWell(
              onTap: () => onSelected(option),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (_) => const Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Icon(
                            LucideIcons.star,
                            size: 18,
                            color: AppColors.warning,
                            fill: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: AppTextStyles.doctorMeta.copyWith(
                          color: AppColors.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Radio<String>(
                      value: option,
                      groupValue: selected,
                      onChanged: (_) => onSelected(option),
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
