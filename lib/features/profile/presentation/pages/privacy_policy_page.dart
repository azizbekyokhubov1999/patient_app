import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../manager/privacy_policy_cubit.dart';
import '../manager/privacy_policy_state.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const TextStyle _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.25,
  );

  static const TextStyle _bodyStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    height: 1.55,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: 'Privacy Policy',
        backgroundColor: AppColors.white,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppPaths.profile);
          }
        },
      ),
      body: BlocBuilder<PrivacyPolicyCubit, PrivacyPolicyState>(
        builder: (context, state) {
          return switch (state) {
            PrivacyPolicyLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            PrivacyPolicyError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: () =>
                            context.read<PrivacyPolicyCubit>().loadPrivacyPolicy(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            PrivacyPolicyLoaded(
              :final cancellationPolicyText,
              :final termsAndConditionsText,
            ) =>
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  AppSpacing.lg,
                  20,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PolicySection(
                      title: 'Cancelation Policy',
                      body: cancellationPolicyText,
                      titleStyle: _sectionTitleStyle,
                      bodyStyle: _bodyStyle,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _PolicySection(
                      title: 'Terms & Condition',
                      body: termsAndConditionsText,
                      titleStyle: _sectionTitleStyle,
                      bodyStyle: _bodyStyle,
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.title,
    required this.body,
    required this.titleStyle,
    required this.bodyStyle,
  });

  final String title;
  final String body;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;

  @override
  Widget build(BuildContext context) {
    final paragraphs = body
        .trim()
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: AppSpacing.lg),
        ...paragraphs.map(
          (paragraph) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              paragraph.trim(),
              style: bodyStyle,
            ),
          ),
        ),
      ],
    );
  }
}
