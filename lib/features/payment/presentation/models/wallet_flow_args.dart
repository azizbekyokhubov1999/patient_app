import '../manager/payment_cubit.dart';
import '../manager/wallet_cubit.dart';

/// Carries wallet flow cubits across GoRouter child routes.
class WalletFlowArgs {
  const WalletFlowArgs({
    required this.walletCubit,
    required this.paymentCubit,
  });

  final WalletCubit walletCubit;
  final PaymentCubit paymentCubit;
}

/// Top-up success route payload with cubits to restore wallet state.
class TopUpSuccessArgs {
  const TopUpSuccessArgs({
    required this.amount,
    required this.walletFlow,
  });

  final double amount;
  final WalletFlowArgs walletFlow;
}
