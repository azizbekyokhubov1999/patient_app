import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/coupon_model.dart';
import '../manager/coupons_cubit.dart';
import '../manager/coupons_state.dart';
import '../widgets/coupon_card.dart';

class MyCouponsPage extends StatelessWidget {
  const MyCouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'My Coupon',
        backgroundColor: AppColors.background,
      ),
      body: BlocBuilder<CouponsCubit, CouponsState>(
        builder: (context, state) {
          return switch (state) {
            CouponsInitial() || CouponsLoading() => const _CouponListSkeleton(),
            CouponsError(:final message) => _CouponsErrorView(message: message),
            CouponsLoaded(:final coupons) when coupons.isEmpty =>
              const _CouponsEmptyView(),
            CouponsLoaded(:final coupons) =>
              _CouponsListView(coupons: coupons),
          };
        },
      ),
    );
  }
}

class _CouponsListView extends StatelessWidget {
  const _CouponsListView({required this.coupons});

  final List<CouponModel> coupons;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      itemCount: coupons.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(
              'Coupons for you',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
            ),
          );
        }

        final couponIndex = index - 1;
        return Padding(
          padding: EdgeInsets.only(
            bottom: couponIndex < coupons.length - 1 ? AppSpacing.lg : 0,
          ),
          child: CouponCard(coupon: coupons[couponIndex]),
        );
      },
    );
  }
}

class _CouponsEmptyView extends StatelessWidget {
  const _CouponsEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 88,
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              "You don't have any coupons yet",
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponsErrorView extends StatelessWidget {
  const _CouponsErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => context.read<CouponsCubit>().loadCoupons(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponListSkeleton extends StatefulWidget {
  const _CouponListSkeleton();

  @override
  State<_CouponListSkeleton> createState() => _CouponListSkeletonState();
}

class _CouponListSkeletonState extends State<_CouponListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.35 + (_controller.value * 0.35);
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          children: [
            _SkeletonBar(width: 160, height: 22, opacity: opacity),
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < 3; i++) ...[
              _SkeletonBar(
                width: double.infinity,
                height: 168,
                opacity: opacity,
                borderRadius: 16,
              ),
              if (i < 2) const SizedBox(height: AppSpacing.lg),
            ],
          ],
        );
      },
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.width,
    required this.height,
    required this.opacity,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double opacity;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutral200.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
