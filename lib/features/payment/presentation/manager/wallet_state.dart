import '../../data/models/transaction_model.dart';

/// Top-up flow status while [WalletLoaded] is active.
abstract final class TopUpStatus {
  static const String idle = 'idle';
  static const String loading = 'loading';
  static const String success = 'success';
  static const String failure = 'failure';
}

sealed class WalletState {
  const WalletState();
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  const WalletLoaded({
    required this.balance,
    required this.walletId,
    required this.transactions,
    this.topUpStatus = TopUpStatus.idle,
    this.topUpErrorMessage,
  });

  final double balance;
  final String walletId;
  final List<TransactionModel> transactions;
  final String topUpStatus;
  final String? topUpErrorMessage;

  bool get isTopUpLoading => topUpStatus == TopUpStatus.loading;
  bool get isTopUpSuccess => topUpStatus == TopUpStatus.success;
  bool get isTopUpFailure => topUpStatus == TopUpStatus.failure;

  WalletLoaded copyWith({
    double? balance,
    String? walletId,
    List<TransactionModel>? transactions,
    String? topUpStatus,
    Object? topUpErrorMessage = _sentinel,
  }) {
    return WalletLoaded(
      balance: balance ?? this.balance,
      walletId: walletId ?? this.walletId,
      transactions: transactions ?? this.transactions,
      topUpStatus: topUpStatus ?? this.topUpStatus,
      topUpErrorMessage: identical(topUpErrorMessage, _sentinel)
          ? this.topUpErrorMessage
          : topUpErrorMessage as String?,
    );
  }

  static const Object _sentinel = Object();
}

class WalletError extends WalletState {
  const WalletError(this.message);

  final String message;
}
