import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';
import '../models/transaction_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._remote);

  final WalletRemoteDataSource _remote;

  @override
  Stream<double> getWalletBalance(String uid) => _remote.getWalletBalance(uid);

  @override
  Stream<List<TransactionModel>> getWalletTransactions(String uid) =>
      _remote.getWalletTransactions(uid);

  @override
  Future<void> deductWalletBalance(
    String uid,
    double amount,
    String description,
  ) =>
      _remote.deductWalletBalance(uid, amount, description);

  @override
  Future<void> addMoneyToWallet(String uid, double amount) =>
      _remote.addMoneyToWallet(uid, amount);
}
