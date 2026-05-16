import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared app bar with circular bordered back control (Figma-style).
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title,
    this.onBack,
    this.backgroundColor = Colors.transparent,
    this.surfaceTintColor = Colors.transparent,
    this.centerTitle = true,
    this.actions,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final Color backgroundColor;
  final Color surfaceTintColor;
  final bool centerTitle;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: surfaceTintColor,
      elevation: 0,
      centerTitle: centerTitle,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onBack ?? () => context.pop(),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.stroke),
              color: AppColors.white,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppColors.primaryText,
            ),
          ),
        ),
      ),
      title: title.isEmpty
          ? null
          : Text(
              title,
              style: AppTextStyles.titleMedium,
            ),
      actions: actions,
    );
  }
}

/// Circular icon action used on map overlays (optional).
class CustomAppBarIconButton extends StatelessWidget {
  const CustomAppBarIconButton({
    required this.icon,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.stroke),
          color: AppColors.white,
        ),
        child: Icon(icon, size: 20, color: AppColors.primaryText),
      ),
    );
  }
}

/// Lucide search variant for pages that need it.
class CustomAppBarSearchButton extends CustomAppBarIconButton {
  const CustomAppBarSearchButton({required super.onTap, super.key})
      : super(icon: LucideIcons.search);
}
