import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/coupon_model.dart';

abstract class CouponsRemoteDataSource {
  Future<List<CouponModel>> getCoupons();

  Future<double> getUserWalletBalance(String uid);
}

class CouponsRemoteDataSourceImpl implements CouponsRemoteDataSource {
  CouponsRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<CouponModel>> getCoupons() async {
    final snapshot = await _firestore.collection('coupons').get();
    return snapshot.docs.map(CouponModel.fromFirestore).toList();
  }

  @override
  Future<double> getUserWalletBalance(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    return (data['walletBalance'] as num?)?.toDouble() ??
        (data['wallet_balance'] as num?)?.toDouble() ??
        (data['balance'] as num?)?.toDouble() ??
        0;
  }
}
