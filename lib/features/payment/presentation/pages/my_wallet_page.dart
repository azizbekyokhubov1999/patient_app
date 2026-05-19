import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/transaction_model.dart';
import '../manager/wallet_cubit.dart';
import '../manager/wallet_state.dart';
import '../utils/wallet_transaction_grouper.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_transaction_tile.dart';

class MyWalletPage extends StatelessWidget {
  const MyWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: 'My Wallet',
        backgroundColor: AppColors.white,
      ),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          return switch (state) {
            WalletInitial() || WalletLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            WalletError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            context.read<WalletCubit>().listenToWallet(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            WalletLoaded(
              :final balance,
              :final walletId,
              :final transactions,
            ) =>
              _WalletLoadedBody(
                balance: balance,
                walletId: walletId,
                transactions: transactions,
              ),
          };
        },
      ),
    );
  }
}

class _WalletLoadedBody extends StatelessWidget {
  const _WalletLoadedBody({
    required this.balance,
    required this.walletId,
    required this.transactions,
  });

  final double balance;
  final String walletId;
  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    final groups = groupWalletTransactions(transactions);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: _itemCount(groups),
      itemBuilder: (context, index) {
        if (index == 0) {
          return WalletBalanceCard(
            balance: balance,
            walletId: walletId,
            onAddMoney: () => context.push(AppPaths.addMoney),
          );
        }

        final groupIndex = index - 1;
        final group = groups[groupIndex];

        return Padding(
          padding: EdgeInsets.only(top: groupIndex == 0 ? 24 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: Text(
                  group.header,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              ...group.transactions.map(
                (tx) => WalletTransactionTile(transaction: tx),
              ),
            ],
          ),
        );
      },
    );
  }

  int _itemCount(List<WalletTransactionGroup> groups) {
    return groups.isEmpty ? 1 : 1 + groups.length;
  }
}
