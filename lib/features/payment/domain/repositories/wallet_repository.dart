import '../../data/models/transaction_model.dart';

abstract class WalletRepository {
  Stream<double> getWalletBalance(String uid);

  Stream<List<TransactionModel>> getWalletTransactions(String uid);

  Future<void> deductWalletBalance(
    String uid,
    double amount,
    String description,
  );

  Future<void> addMoneyToWallet(String uid, double amount);
}
