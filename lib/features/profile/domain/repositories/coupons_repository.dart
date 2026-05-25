import '../../data/models/coupon_model.dart';

abstract class CouponsRepository {
  Future<List<CouponModel>> loadCoupons({required String userId});
}
