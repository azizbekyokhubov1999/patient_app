import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/wallet_flow_args.dart';
import '../utils/wallet_navigation.dart';
import '../widgets/top_up_success_badge.dart';

class TopUpSuccessfulPage extends StatelessWidget {
  const TopUpSuccessfulPage({
    required this.amount,
    this.walletFlow,
    super.key,
  });

  final double amount;
  final WalletFlowArgs? walletFlow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TopUpSuccessBadge(),
                      const SizedBox(height: 32),
                      Text(
                        'Top Up Successful!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You have successfully Top-Up e-wallet for \$${amount.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.doctorMeta.copyWith(
                          fontSize: 16,
                          height: 1.45,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      completeTopUpFlow(context, walletFlow: walletFlow),
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
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
