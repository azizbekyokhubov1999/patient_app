import '../../data/models/coupon_model.dart';

sealed class CouponsState {
  const CouponsState();
}

class CouponsInitial extends CouponsState {
  const CouponsInitial();
}

class CouponsLoading extends CouponsState {
  const CouponsLoading();
}

class CouponsLoaded extends CouponsState {
  const CouponsLoaded(this.coupons);

  final List<CouponModel> coupons;
}

class CouponsError extends CouponsState {
  const CouponsError(this.message);

  final String message;
}
