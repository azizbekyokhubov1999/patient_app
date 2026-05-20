import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../manager/payment_cubit.dart';
import '../manager/payment_state.dart';
import '../manager/wallet_cubit.dart';
import '../manager/wallet_state.dart';
import '../models/wallet_flow_args.dart';
import '../utils/wallet_flow_provider.dart';

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({super.key});

  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  final _amountController = TextEditingController();
  String? _selectedPaymentSourceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final paymentState = context.read<PaymentCubit>().state;
      if (paymentState.isLoaded && _selectedPaymentSourceId == null) {
        setState(() {
          _selectedPaymentSourceId = paymentState.defaultMethodId ??
              (paymentState.cards.isNotEmpty
                  ? PaymentMethodIds.card(paymentState.cards.first.id)
                  : PaymentMethodIds.paypal);
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final text = _amountController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _selectQuickAmount(double value) {
    setState(() {
      _amountController.text = value.toStringAsFixed(0);
    });
  }

  void _submit() {
    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    if (_selectedPaymentSourceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment source')),
      );
      return;
    }

    context.read<WalletCubit>().executeTopUp(
          amount: amount,
          paymentSourceId: _selectedPaymentSourceId!,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listenWhen: (previous, current) {
        if (previous is WalletLoaded && current is WalletLoaded) {
          return previous.topUpStatus != current.topUpStatus;
        }
        return false;
      },
      listener: (context, state) {
        if (state is! WalletLoaded) return;

        if (state.isTopUpSuccess) {
          final amount = _parseAmount() ?? 0;
          final walletFlow = readWalletFlowArgs(context);
          context.read<WalletCubit>().clearTopUpStatus();
          context.push(
            AppPaths.topUpSuccess,
            extra: TopUpSuccessArgs(
              amount: amount,
              walletFlow: walletFlow,
            ),
          );
          return;
        }

        if (state.isTopUpFailure && state.topUpErrorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.topUpErrorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<WalletCubit>().clearTopUpStatus();
        }
      },
      builder: (context, walletState) {
        if (walletState is WalletInitial || walletState is WalletLoading) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            appBar: CustomAppBar(
              title: 'Add Money',
              backgroundColor: AppColors.white,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (walletState is WalletError) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: const CustomAppBar(
              title: 'Add Money',
              backgroundColor: AppColors.white,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  walletState.message,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final balance = walletState is WalletLoaded ? walletState.balance : 0.0;
        final isSubmitting =
            walletState is WalletLoaded && walletState.isTopUpLoading;

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: const CustomAppBar(
            title: 'Add Money',
            backgroundColor: AppColors.white,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  MediaQuery.viewInsetsOf(context).bottom + 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AddMoneyCard(
                      balance: balance,
                      amountController: _amountController,
                      onQuickAmount: _selectQuickAmount,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Select Payment Source',
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 12),
                    _PaymentSourceSelector(
                      selectedId: _selectedPaymentSourceId,
                      onSelected: (id) =>
                          setState(() => _selectedPaymentSourceId = id),
                    ),
                  ],
                ),
              ),
              if (isSubmitting)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 16 + MediaQuery.paddingOf(context).bottom,
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Add Money',
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
          ),
        );
      },
    );
  }
}

class _AddMoneyCard extends StatelessWidget {
  const _AddMoneyCard({
    required this.balance,
    required this.amountController,
    required this.onQuickAmount,
  });

  final double balance;
  final TextEditingController amountController;
  final ValueChanged<double> onQuickAmount;

  static const Color _cardBg = Color(0xFFEAF2FF);

  static const List<double> _amounts = [
    100,
    200,
    500,
    1000,
    2000,
    3000,
    4000,
    5000,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '\$ ${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _amounts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.4,
            ),
            itemBuilder: (context, index) {
              final value = _amounts[index];
              return _AmountChip(
                label: '+ \$${value.toStringAsFixed(0)}',
                onTap: () => onQuickAmount(value),
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Enter Amount',
                      hintStyle: TextStyle(color: AppColors.secondaryText),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentSourceSelector extends StatelessWidget {
  const _PaymentSourceSelector({
    required this.selectedId,
    required this.onSelected,
  });

  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        final sources = <_PaymentSourceOption>[];

        if (state.isLoaded) {
          for (final card in state.cards) {
            sources.add(
              _PaymentSourceOption(
                id: PaymentMethodIds.card(card.id),
                label: 'Visa **** ${card.lastFour}',
                icon: Icons.credit_card,
              ),
            );
          }
          sources.addAll(const [
            _PaymentSourceOption(
              id: PaymentMethodIds.paypal,
              label: 'Paypal',
              icon: Icons.account_balance_wallet_outlined,
            ),
            _PaymentSourceOption(
              id: PaymentMethodIds.applePay,
              label: 'Apple Pay',
              icon: Icons.apple,
            ),
            _PaymentSourceOption(
              id: PaymentMethodIds.googlePay,
              label: 'Google Pay',
              icon: Icons.g_mobiledata,
            ),
          ]);
        } else if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          sources.addAll(const [
            _PaymentSourceOption(
              id: PaymentMethodIds.paypal,
              label: 'Paypal',
              icon: Icons.account_balance_wallet_outlined,
            ),
            _PaymentSourceOption(
              id: PaymentMethodIds.applePay,
              label: 'Apple Pay',
              icon: Icons.apple,
            ),
          ]);
        }

        return SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sources.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final source = sources[index];
              final selected = selectedId == source.id;
              return GestureDetector(
                onTap: () => onSelected(source.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.stroke,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(source.icon, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        source.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PaymentSourceOption {
  const _PaymentSourceOption({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}
