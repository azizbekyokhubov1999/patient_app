import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../models/wallet_flow_args.dart';

/// Pops the top-up flow (success + add-money) back to [AppPaths.myWallet].
void completeTopUpFlow(
  BuildContext context, {
  WalletFlowArgs? walletFlow,
}) {
  var pops = 0;
  while (context.canPop() && pops < 2) {
    context.pop();
    pops++;
  }

  final onWallet =
      GoRouterState.of(context).uri.path == AppPaths.myWallet;

  if (!onWallet) {
    if (walletFlow != null) {
      context.go(AppPaths.myWallet, extra: walletFlow);
    } else {
      context.go(AppPaths.myWallet);
    }
  }
}

/// Safe back from wallet: pop to profile or fall back to profile tab.
void popWalletOrGoProfile(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppPaths.profile);
  }
}
