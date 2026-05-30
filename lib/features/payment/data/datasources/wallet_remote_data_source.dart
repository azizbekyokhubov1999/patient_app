import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';

abstract class WalletRemoteDataSource {
  Stream<double> getWalletBalance(String uid);

  Stream<List<TransactionModel>> getWalletTransactions(String uid);

  Future<void> deductWalletBalance(
    String uid,
    double amount,
    String description,
  );

  Future<void> addMoneyToWallet(String uid, double amount);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  WalletRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Stream<double> getWalletBalance(String uid) {
    return _userRef(uid).snapshots().map((snapshot) {
      final data = snapshot.data() ?? {};
      return (data['walletBalance'] as num?)?.toDouble() ??
          (data['wallet_balance'] as num?)?.toDouble() ??
          (data['balance'] as num?)?.toDouble() ??
          0;
    });
  }

  @override
  Stream<List<TransactionModel>> getWalletTransactions(String uid) {
    return _userRef(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(TransactionModel.fromFirestore)
              .toList(growable: false),
        );
  }

  @override
  Future<void> deductWalletBalance(
    String uid,
    double amount,
    String description,
  ) async {
    await _firestore.runTransaction((transaction) async {
      final userRef = _userRef(uid);
      final userSnap = await transaction.get(userRef);
      final data = userSnap.data() ?? {};
      final currentBalance = (data['walletBalance'] as num?)?.toDouble() ??
          (data['wallet_balance'] as num?)?.toDouble() ??
          (data['balance'] as num?)?.toDouble() ??
          0;

      if (currentBalance < amount) {
        throw Exception('Insufficient wallet balance');
      }

      final newBalance = currentBalance - amount;
      transaction.update(userRef, {'walletBalance': newBalance});

      final txRef = userRef.collection('transactions').doc();
      transaction.set(txRef, {
        'title': description,
        'amount': amount,
        'isCredit': false,
        'date': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> addMoneyToWallet(String uid, double amount) async {
    await _firestore.runTransaction((transaction) async {
      final userRef = _userRef(uid);

      transaction.update(userRef, {
        'walletBalance': FieldValue.increment(amount),
      });

      final txRef = userRef.collection('transactions').doc();
      transaction.set(txRef, {
        'title': 'Money Added to Wallet',
        'amount': amount,
        'isCredit': true,
        'date': FieldValue.serverTimestamp(),
      });
    });
  }
}
