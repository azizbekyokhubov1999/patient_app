import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/mock_data.dart';
import '../../data/datasources/wallet_remote_data_source.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit({
    FirebaseAuth? auth,
    WalletRepository? repository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _repository = repository ??
            WalletRepositoryImpl(WalletRemoteDataSourceImpl()),
        super(const WalletInitial());

  final FirebaseAuth _auth;
  final WalletRepository _repository;

  StreamSubscription<double>? _balanceSub;
  StreamSubscription<List<TransactionModel>>? _transactionsSub;

  double _balance = 0;
  String _walletId = '';
  List<TransactionModel> _transactions = const [];

  void loadWalletDetails() {
    emit(const WalletLoading());

    unawaited(_balanceSub?.cancel());
    unawaited(_transactionsSub?.cancel());

    if (kUseProfileMockData) {
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) _emitMockWallet();
      });
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(const WalletError('No signed-in user'));
      return;
    }

    _walletId = uid.substring(0, 8).toUpperCase();

    _balanceSub = _repository.getWalletBalance(uid).listen(
      (balance) {
        _balance = balance;
        _tryEmitLoaded();
      },
      onError: _onStreamError,
    );

    _transactionsSub = _repository.getWalletTransactions(uid).listen(
      (transactions) {
        _transactions = transactions;
        _tryEmitLoaded();
      },
      onError: _onStreamError,
    );
  }

  void listenToWallet() => loadWalletDetails();

  Future<void> addMoney(double amount) async {
    if (amount <= 0) {
      _emitTopUpFailure('Please enter a valid amount');
      return;
    }

    final current = state;
    if (current is! WalletLoaded) {
      emit(const WalletError('Please enter a valid amount'));
      return;
    }

    emit(current.copyWith(topUpStatus: TopUpStatus.loading, topUpErrorMessage: null));

    try {
      if (kUseProfileMockData) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        final now = DateTime.now();
        final tx = TransactionModel(
          id: 'tx-${now.millisecondsSinceEpoch}',
          title: 'Money Added to Wallet',
          amount: amount,
          isCredit: true,
          date: now,
          postBalance: current.balance + amount,
        );
        _balance = current.balance + amount;
        _transactions = [tx, ...current.transactions];
        emit(
          WalletLoaded(
            balance: _balance,
            walletId: current.walletId,
            transactions: List.unmodifiable(_transactions),
            topUpStatus: TopUpStatus.success,
          ),
        );
        return;
      }

      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        _emitTopUpFailure('Failed to add money. Please try again.');
        return;
      }

      await _repository.addMoneyToWallet(uid, amount);

      final loaded = state;
      if (loaded is WalletLoaded) {
        emit(loaded.copyWith(topUpStatus: TopUpStatus.success));
      }
    } catch (e, st) {
      developer.log('addMoney error', error: e, stackTrace: st);
      _emitTopUpFailure('Failed to add money. Please try again.');
    }
  }

  Future<void> executeTopUp({
    required double amount,
    required String paymentSourceId,
  }) async {
    final current = state;
    if (current is! WalletLoaded || amount <= 0) return;

    emit(current.copyWith(topUpStatus: TopUpStatus.loading, topUpErrorMessage: null));

    try {
      if (kUseProfileMockData) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        final now = DateTime.now();
        final tx = TransactionModel(
          id: 'tx-${now.millisecondsSinceEpoch}',
          title: 'Money Added to Wallet',
          amount: amount,
          isCredit: true,
          date: now,
          postBalance: current.balance + amount,
        );
        _balance = current.balance + amount;
        _transactions = [tx, ...current.transactions];
        emit(
          WalletLoaded(
            balance: _balance,
            walletId: current.walletId,
            transactions: List.unmodifiable(_transactions),
            topUpStatus: TopUpStatus.success,
          ),
        );
        return;
      }

      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(
          current.copyWith(
            topUpStatus: TopUpStatus.failure,
            topUpErrorMessage: 'No signed-in user',
          ),
        );
        return;
      }

      await _repository.addMoneyToWallet(uid, amount);

      emit(
        current.copyWith(
          topUpStatus: TopUpStatus.success,
          topUpErrorMessage: null,
        ),
      );
    } catch (e, st) {
      developer.log('executeTopUp error', error: e, stackTrace: st);
      emit(
        current.copyWith(
          topUpStatus: TopUpStatus.failure,
          topUpErrorMessage: e.toString(),
        ),
      );
    }
  }

  void clearTopUpStatus() {
    final current = state;
    if (current is WalletLoaded) {
      emit(current.copyWith(topUpStatus: TopUpStatus.idle, topUpErrorMessage: null));
    }
  }

  void _emitTopUpFailure(String message) {
    final current = state;
    if (current is WalletLoaded) {
      emit(
        current.copyWith(
          topUpStatus: TopUpStatus.failure,
          topUpErrorMessage: message,
        ),
      );
      return;
    }
    emit(WalletError(message));
  }

  void _tryEmitLoaded() {
    if (isClosed) return;
    final previous = state;
    final topUpStatus =
        previous is WalletLoaded ? previous.topUpStatus : TopUpStatus.idle;

    emit(
      WalletLoaded(
        balance: _balance,
        walletId: _walletId,
        transactions: List.unmodifiable(_transactions),
        topUpStatus: topUpStatus == TopUpStatus.loading ? topUpStatus : TopUpStatus.idle,
      ),
    );
  }

  void _onStreamError(Object error, StackTrace stackTrace) {
    developer.log('Wallet stream error', error: error, stackTrace: stackTrace);
    if (!isClosed) {
      emit(WalletError(error.toString()));
    }
  }

  void _emitMockWallet() {
    _balance = mockWalletBalanceAmount;
    _walletId = mockWalletId;
    _transactions = mockWalletTransactions();

    emit(
      WalletLoaded(
        balance: _balance,
        walletId: _walletId,
        transactions: List.unmodifiable(_transactions),
      ),
    );
  }

  @override
  Future<void> close() {
    unawaited(_balanceSub?.cancel());
    unawaited(_transactionsSub?.cancel());
    return super.close();
  }
}
