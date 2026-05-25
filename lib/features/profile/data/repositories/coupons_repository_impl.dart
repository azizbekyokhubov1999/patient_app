import '../../domain/repositories/coupons_repository.dart';
import '../datasources/coupons_remote_data_source.dart';
import '../models/coupon_model.dart';

class CouponsRepositoryImpl implements CouponsRepository {
  CouponsRepositoryImpl(this._remote);

  final CouponsRemoteDataSource _remote;

  @override
  Future<List<CouponModel>> loadCoupons({required String userId}) async {
    final walletBalance = await _remote.getUserWalletBalance(userId);
    final coupons = await _remote.getCoupons();
    return coupons.map((c) => c.withWalletBalance(walletBalance)).toList();
  }
}
