import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/datasources/wallet_remote_data_source.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../manager/payment_cubit.dart';
import '../manager/wallet_cubit.dart';
import '../models/wallet_flow_args.dart';

/// Wraps [child] with wallet/payment cubits from [state.extra] or creates fresh instances.
Widget buildWalletFlowScope({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  final extra = state.extra;

  if (extra is WalletFlowArgs) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WalletCubit>.value(value: extra.walletCubit),
        BlocProvider<PaymentCubit>.value(value: extra.paymentCubit),
      ],
      child: child,
    );
  }

  if (extra is TopUpSuccessArgs) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WalletCubit>.value(value: extra.walletFlow.walletCubit),
        BlocProvider<PaymentCubit>.value(value: extra.walletFlow.paymentCubit),
      ],
      child: child,
    );
  }

  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => WalletCubit(
          repository: WalletRepositoryImpl(WalletRemoteDataSourceImpl()),
        )..loadWalletDetails(),
      ),
      BlocProvider(
        create: (_) => PaymentCubit()..loadPaymentMethods(),
      ),
    ],
    child: child,
  );
}

WalletFlowArgs readWalletFlowArgs(BuildContext context) {
  return WalletFlowArgs(
    walletCubit: context.read<WalletCubit>(),
    paymentCubit: context.read<PaymentCubit>(),
  );
}
