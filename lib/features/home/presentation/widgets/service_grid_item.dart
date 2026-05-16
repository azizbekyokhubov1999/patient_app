import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/service_category.dart';

/// Service chip for the 4-column services grid.
///
/// The grid uses a fixed [childAspectRatio]; on narrow phones or with large
/// text scaling, intrinsic content can exceed the cell. We wrap the column in
/// [FittedBox] + [BoxFit.scaleDown] so the whole tile shrinks uniformly and
/// never overflows.
class ServiceGridItem extends StatelessWidget {
  const ServiceGridItem({
    required this.category,
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  final ServiceCategory category;
  final VoidCallback onTap;
  final bool isSelected;

  static const Color _idleCircleFill = Color(0xFFF0F4FF);
  static const Color _labelColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? AppColors.white : AppColors.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Align(
            alignment: Alignment.topCenter,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor:
                          isSelected ? AppColors.primary : _idleCircleFill,
                      child: SvgPicture.asset(
                        category.iconAsset,
                        width: 30,
                        height: 30,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      strutStyle: StrutStyle(
                        fontSize: 12,
                        height: 1.15,
                        leading: 0,
                        fontWeight: FontWeight.w500,
                        forceStrutHeight: true,
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _labelColor,
                            height: 1.15,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
