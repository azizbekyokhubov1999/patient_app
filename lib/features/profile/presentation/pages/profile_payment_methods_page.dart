import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../booking/domain/entities/card_model.dart';
import '../../../payment/presentation/manager/payment_cubit.dart';
import '../../../payment/presentation/manager/payment_state.dart';
import '../../../payment/presentation/widgets/payment_method_tile.dart';

class ProfilePaymentMethodsPage extends StatelessWidget {
  const ProfilePaymentMethodsPage({super.key});

  Future<void> _openAddCard(BuildContext context) async {
    final card = await context.push<CardModel>(AppPaths.addCard);
    if (card != null && context.mounted) {
      await context.read<PaymentCubit>().addSavedCard(card);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentCubit(localOnly: true),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: const CustomAppBar(
          title: 'Payment Methods',
          backgroundColor: AppColors.white,
        ),
        body: BlocBuilder<PaymentCubit, PaymentState>(
          builder: (context, state) {
            final defaultId = state.defaultMethodId;

            return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credit & Debit Card',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (state.cards.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.stroke),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (var i = 0; i < state.cards.length; i++)
                                PaymentMethodTile(
                                  title: state.cards[i].maskedNumber,
                                  icon: Icons.credit_card_outlined,
                                  isSelected: defaultId ==
                                      PaymentMethodIds.card(state.cards[i].id),
                                  isRadioType: true,
                                  showBottomDivider:
                                      i < state.cards.length - 1,
                                  onTap: () => context
                                      .read<PaymentCubit>()
                                      .setDefaultPaymentMethod(
                                        PaymentMethodIds.card(
                                          state.cards[i].id,
                                        ),
                                      ),
                                ),
                            ],
                          ),
                        ),
                      if (state.cards.isNotEmpty) const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: PaymentMethodTile(
                          title: 'Add Card',
                          icon: Icons.credit_card_outlined,
                          isRadioType: false,
                          onTap: () => _openAddCard(context),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'More Payment Options',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            PaymentMethodTile(
                              title: 'Paypal',
                              iconAssetPath: 'assets/images/logo1.png',
                              isSelected:
                                  defaultId == PaymentMethodIds.paypal,
                              showBottomDivider: true,
                              onTap: () => context
                                  .read<PaymentCubit>()
                                  .setDefaultPaymentMethod(
                                    PaymentMethodIds.paypal,
                                  ),
                            ),
                            PaymentMethodTile(
                              title: 'Apple Pay',
                              iconAssetPath:
                                  'assets/images/apple-black-logo.svg',
                              isSvgAsset: true,
                              isSelected:
                                  defaultId == PaymentMethodIds.applePay,
                              showBottomDivider: true,
                              onTap: () => context
                                  .read<PaymentCubit>()
                                  .setDefaultPaymentMethod(
                                    PaymentMethodIds.applePay,
                                  ),
                            ),
                            PaymentMethodTile(
                              title: 'Google Pay',
                              iconAssetPath: 'assets/images/google-icon.svg',
                              isSvgAsset: true,
                              isSelected:
                                  defaultId == PaymentMethodIds.googlePay,
                              onTap: () => context
                                  .read<PaymentCubit>()
                                  .setDefaultPaymentMethod(
                                    PaymentMethodIds.googlePay,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}
