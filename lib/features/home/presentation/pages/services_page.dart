import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/service_category.dart';
import '../widgets/service_grid_item.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => context.pop(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.stroke),
                color: AppColors.white,
              ),
              child: const Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Services',
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
          /// Slightly shorter cells than strict math needs — [ServiceGridItem]
          /// uses [FittedBox] to scale down if needed; ratio still affects
          /// default size and scroll density.
          childAspectRatio: 0.68,
        ),
        itemCount: mockServices.length,
        itemBuilder: (context, index) {
          final category = mockServices[index];
          return ServiceGridItem(
            category: category,
            isSelected: false,
            onTap: () => context.pop<ServiceCategory>(category),
          );
        },
      ),
    );
  }
}
