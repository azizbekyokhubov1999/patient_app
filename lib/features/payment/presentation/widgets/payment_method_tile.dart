import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';

/// Shared payment row — radio selection or chevron navigation (Figma).
class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    required this.title,
    required this.onTap,
    this.icon,
    this.iconAssetPath,
    this.isSvgAsset = false,
    this.isSelected = false,
    this.isRadioType = true,
    this.showBottomDivider = false,
    super.key,
  });

  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final String? iconAssetPath;
  final bool isSvgAsset;
  final bool isSelected;
  final bool isRadioType;
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Material(
          color: AppColors.white,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _LeadingIcon(
                    icon: icon,
                    assetPath: iconAssetPath,
                    isSvg: isSvgAsset,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  if (isRadioType)
                    _RadioIndicator(selected: isSelected)
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary.withValues(alpha: 0.85),
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showBottomDivider)
          const Divider(height: 1, thickness: 1, color: AppColors.stroke),
      ],
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({
    this.icon,
    this.assetPath,
    this.isSvg = false,
  });

  final IconData? icon;
  final String? assetPath;
  final bool isSvg;

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      if (isSvg) {
        return SizedBox(
          width: 28,
          height: 28,
          child: SvgPicture.asset(
            assetPath!,
            fit: BoxFit.contain,
          ),
        );
      }
      return Image.asset(
        assetPath!,
        width: 28,
        height: 28,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          icon ?? Icons.payment,
          color: AppColors.primary,
          size: 24,
        ),
      );
    }

    return Icon(
      icon ?? Icons.payment,
      color: AppColors.primary,
      size: 24,
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.stroke,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
