import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RecentSearchChips extends StatelessWidget {
  const RecentSearchChips({
    required this.keywords,
    required this.onKeywordTap,
    required this.onRemoveKeyword,
    required this.onClearAll,
    super.key,
  });

  final List<String> keywords;
  final ValueChanged<String> onKeywordTap;
  final ValueChanged<String> onRemoveKeyword;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Search',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
            ),
            const Spacer(),
            TextButton(
              onPressed: onClearAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.warning,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Clear All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: keywords
              .map(
                (keyword) => InputChip(
                  label: Text(keyword),
                  labelStyle: AppTextStyles.doctorMeta.copyWith(
                    color: AppColors.primaryText,
                    fontSize: 14,
                  ),
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  deleteIcon: const Icon(
                    LucideIcons.x,
                    size: 16,
                    color: AppColors.secondaryText,
                  ),
                  onDeleted: () => onRemoveKeyword(keyword),
                  onPressed: () => onKeywordTap(keyword),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
