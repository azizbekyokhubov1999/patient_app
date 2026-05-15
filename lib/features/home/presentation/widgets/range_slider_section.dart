import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RangeSliderSection extends StatelessWidget {
  const RangeSliderSection({
    required this.title,
    required this.values,
    required this.min,
    required this.max,
    required this.scaleLabels,
    required this.onChanged,
    this.divisions,
    super.key,
  });

  final String title;
  final RangeValues values;
  final double min;
  final double max;
  final List<String> scaleLabels;
  final ValueChanged<RangeValues> onChanged;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.neutral200,
            thumbColor: AppColors.primary,
          ),
          child: RangeSlider(
            values: values,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: scaleLabels
              .map(
                (label) => Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.doctorMeta.copyWith(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
