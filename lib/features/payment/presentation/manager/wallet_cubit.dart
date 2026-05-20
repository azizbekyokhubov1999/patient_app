import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/mock_data.dart';
import '../../data/models/transaction_model.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const WalletInitial());

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _walletSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _transactionsSub;

  double _balance = 0;
  String _walletId = '';
  List<TransactionModel> _transactions = const [];

  void listenToWallet() {
    emit(const WalletLoading());

    unawaited(_walletSub?.cancel());
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

    _walletSub = _firestore.collection('users').doc(uid).snapshots().listen(
      (snapshot) {
        final data = snapshot.data() ?? {};
        _balance = (data['balance'] as num?)?.toDouble() ??
            (data['wallet_balance'] as num?)?.toDouble() ??
            0;
        _walletId = data['walletId'] as String? ?? '';
        _tryEmitLoaded();
      },
      onError: _onStreamError,
    );

    _transactionsSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _transactions = snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
            .toList();
        _tryEmitLoaded();
      },
      onError: _onStreamError,
    );
  }

  Future<void> executeTopUp({
    required double amount,
    required String paymentSourceId,
  }) async {
    final current = state;
    if (current is! WalletLoaded || amount <= 0) return;

    emit(current.copyWith(topUpStatus: TopUpStatus.loading, topUpErrorMessage: null));

    final newBalance = current.balance + amount;
    final now = DateTime.now();
    final transaction = TransactionModel(
      id: '',
      title: 'Money Added to Wallet',
      timestamp: now,
      amount: amount,
      type: 'income',
      postBalance: newBalance,
    );

    try {
      if (kUseProfileMockData) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        final tx = transaction.copyWith(id: 'tx-${now.millisecondsSinceEpoch}');
        _balance = newBalance;
        _transactions = [tx, ...current.transactions];
        emit(
          WalletLoaded(
            balance: newBalance,
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

      final batch = _firestore.batch();
      final userRef = _firestore.collection('users').doc(uid);
      final walletRef = userRef.collection('wallet').doc('wallet');
      final txRef = userRef.collection('transactions').doc();

      batch.set(
        walletRef,
        {
          'wallet_balance': newBalance,
          'balance': newBalance,
          'walletId': current.walletId,
        },
        SetOptions(merge: true),
      );
      batch.set(userRef, {'balance': newBalance}, SetOptions(merge: true));
      batch.set(txRef, transaction.toMap());

      await batch.commit();

      final savedTx = transaction.copyWith(id: txRef.id);
      _balance = newBalance;
      _transactions = [savedTx, ...current.transactions];

      emit(
        WalletLoaded(
          balance: newBalance,
          walletId: current.walletId,
          transactions: List.unmodifiable(_transactions),
          topUpStatus: TopUpStatus.success,
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
    unawaited(_walletSub?.cancel());
    unawaited(_transactionsSub?.cancel());
    return super.close();
  }
}
