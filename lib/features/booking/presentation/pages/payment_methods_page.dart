import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/package_type.dart';
import '../../domain/entities/payment_method_type.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../models/booking_route_args.dart';
import '../widgets/payment_method_tile.dart';
import '../../domain/entities/card_model.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({
    required this.args,
    super.key,
  });

  final PaymentMethodArgs args;

  @override
  Widget build(BuildContext context) {
    final doctorId = args.doctorId ?? args.doctor?.name.toLowerCase().replaceAll(' ', '_') ?? 'doctor';

    return BlocProvider(
      create: (_) => BookingBloc(
        repository: BookingRepositoryImpl(BookingRemoteDataSourceImpl()),
        doctorId: doctorId,
        initialDate: args.selectedDate,
        initialSelectedPackage: args.selectedPackage,
        initialPatientInfo: args.patientInfo,
        initialSelectedPaymentMethod: args.selectedPaymentMethod,
        initialWalletBalance: args.walletBalance,
        initialSavedCards: args.savedCards,
        initialSelectedCardId: args.selectedCardId,
      ),
      child: _PaymentMethodsView(args: args),
    );
  }
}

class _PaymentMethodsView extends StatelessWidget {
  const _PaymentMethodsView({required this.args});

  final PaymentMethodArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        final selectedMethod = state.selectedPaymentMethod;

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    color: AppColors.primaryText,
                    size: 20,
                  ),
                ),
              ),
            ),
            title: const Text('Payment Methods', style: AppTextStyles.appBarTitle),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Wallet ',
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 34 / 2),
                    children: [
                      TextSpan(
                        text: '(Balance : \$${state.walletBalance.toStringAsFixed(2)})',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 34 / 2,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PaymentMethodTile(
                  title: 'Wallet',
                  isSelected: selectedMethod == PaymentMethodType.wallet,
                  onTap: () => context
                      .read<BookingBloc>()
                      .add(const SelectPaymentMethodEvent(PaymentMethodType.wallet)),
                  icon: const _CircleIcon(icon: LucideIcons.walletMinimal),
                  trailing: _RadioDot(
                    selected: selectedMethod == PaymentMethodType.wallet,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Credit & Debit Card',
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 34 / 2),
                ),
                const SizedBox(height: AppSpacing.md),
                if (state.savedCards.isNotEmpty) ...[
                  ...state.savedCards.map(
                    (card) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: PaymentMethodTile(
                        title: _maskedCardTitle(card),
                        isSelected: selectedMethod == PaymentMethodType.creditCard &&
                            state.selectedCardId == card.id,
                        onTap: () => context.read<BookingBloc>().add(SelectSavedCardEvent(card.id)),
                        icon: const _CircleIcon(icon: LucideIcons.creditCard),
                        trailing: _RadioDot(
                          selected: selectedMethod == PaymentMethodType.creditCard &&
                              state.selectedCardId == card.id,
                        ),
                      ),
                    ),
                  ),
                ],
                PaymentMethodTile(
                  title: 'Add Card',
                  isSelected: false,
                  onTap: () async {
                    final newCard = await context.push<CardModel>(AppPaths.addCard);
                    if (newCard == null || !context.mounted) return;
                    context.read<BookingBloc>().add(AddNewCardEvent(newCard));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Card added successfully')),
                    );
                  },
                  icon: const _CircleIcon(icon: LucideIcons.creditCard),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'More Payment Options',
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 34 / 2),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      PaymentMethodTile(
                        title: 'Paypal',
                        isSelected: selectedMethod == PaymentMethodType.payme,
                        onTap: () => context
                            .read<BookingBloc>()
                            .add(const SelectPaymentMethodEvent(PaymentMethodType.payme)),
                        icon: _BrandAssetIcon(
                          assetPath: 'assets/images/logo1.png',
                          fallbackIcon: LucideIcons.walletCards,
                        ),
                        trailing: _RadioDot(selected: selectedMethod == PaymentMethodType.payme),
                        showBottomDivider: true,
                      ),
                      PaymentMethodTile(
                        title: 'Apple Pay',
                        isSelected: selectedMethod == PaymentMethodType.click,
                        onTap: () => context
                            .read<BookingBloc>()
                            .add(const SelectPaymentMethodEvent(PaymentMethodType.click)),
                        icon: _BrandAssetIcon(
                          assetPath: 'assets/images/apple-black-logo.svg',
                          fallbackIcon: LucideIcons.walletCards,
                          isSvg: true,
                        ),
                        trailing: _RadioDot(selected: selectedMethod == PaymentMethodType.click),
                        showBottomDivider: true,
                      ),
                      PaymentMethodTile(
                        title: 'Google Pay',
                        isSelected: selectedMethod == PaymentMethodType.googlePay,
                        onTap: () => context
                            .read<BookingBloc>()
                            .add(const SelectPaymentMethodEvent(PaymentMethodType.googlePay)),
                        icon: _BrandAssetIcon(
                          assetPath: 'assets/images/google-icon.svg',
                          fallbackIcon: LucideIcons.walletCards,
                          isSvg: true,
                        ),
                        trailing: _RadioDot(selected: selectedMethod == PaymentMethodType.googlePay),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: selectedMethod == null
                    ? null
                    : () {
                        if (selectedMethod == PaymentMethodType.wallet &&
                            state.walletBalance < _priceFor(args.selectedPackage)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Insufficient wallet balance for this package.'),
                            ),
                          );
                          return;
                        }

                        context.push(
                          AppPaths.reviewSummary,
                          extra: ReviewSummaryArgs(
                            selectedDate: args.selectedDate,
                            selectedTime: args.selectedTime,
                            selectedPackage: args.selectedPackage,
                            patientInfo: args.patientInfo,
                            selectedPaymentMethod: selectedMethod,
                            walletBalance: state.walletBalance,
                            selectedCardId: state.selectedCardId,
                            doctor: args.doctor,
                            doctorId: args.doctorId,
                            hospital: args.hospital,
                          ),
                        );
                      },
                child: const Text('Confirm Payment', style: AppTextStyles.buttonLabel),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _maskedCardTitle(CardModel card) {
  final digits = card.cardNumber.replaceAll(' ', '');
  if (digits.length < 4) return 'Card';
  return '**** **** **** ${digits.substring(digits.length - 4)}';
}

double _priceFor(PackageType package) {
  switch (package) {
    case PackageType.messaging:
      return 20;
    case PackageType.voiceCall:
      return 40;
    case PackageType.videoCall:
      return 60;
    case PackageType.inPerson:
      return 100;
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: AppColors.primaryText),
    );
  }
}

class _BrandAssetIcon extends StatelessWidget {
  const _BrandAssetIcon({
    required this.assetPath,
    required this.fallbackIcon,
    this.isSvg = false,
  });

  final String assetPath;
  final IconData fallbackIcon;
  final bool isSvg;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(fallbackIcon, size: 18, color: AppColors.primaryText);

    return SizedBox(
      width: 32,
      height: 32,
      child: Center(
        child: isSvg
            ? SvgPicture.asset(
                assetPath,
                width: 22,
                height: 22,
                placeholderBuilder: (_) => fallback,
              )
            : Image.asset(
                assetPath,
                width: 22,
                height: 22,
                errorBuilder: (context, error, _) => fallback,
              ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.outline,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.primary : Colors.transparent,
        ),
      ),
    );
  }
}
