import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/coupon_model.dart';
import 'coupons_state.dart';

const bool _kPresentationMockCoupons = true;

class CouponsCubit extends Cubit<CouponsState> {
  CouponsCubit({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const CouponsInitial());

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> loadCoupons() async {
    emit(const CouponsLoading());

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(const CouponsError('No signed-in user'));
        return;
      }

      final walletBalance = await _fetchWalletBalance(uid);

      if (_kPresentationMockCoupons) {
        await Future<void>.delayed(const Duration(milliseconds: 450));
        final coupons = _mockCoupons()
            .map((c) => c.withWalletBalance(walletBalance))
            .toList();
        emit(CouponsLoaded(coupons));
        return;
      }

      final snapshot = await _firestore.collection('coupons').get();
      final coupons = snapshot.docs
          .map(CouponModel.fromFirestore)
          .map((c) => c.withWalletBalance(walletBalance))
          .toList();

      emit(CouponsLoaded(coupons));
    } catch (e, st) {
      developer.log('loadCoupons error', error: e, stackTrace: st);
      emit(CouponsError(e.toString()));
    }
  }

  Future<double> _fetchWalletBalance(String uid) async {
    if (_kPresentationMockCoupons) {
      return 2400;
    }

    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    return (data['balance'] as num?)?.toDouble() ??
        (data['wallet_balance'] as num?)?.toDouble() ??
        0;
  }

  List<CouponModel> _mockCoupons() {
    return const [
      CouponModel(
        id: 'c1',
        code: 'FIRSTCARE',
        title: 'Get 50% OFF',
        unlockCondition: 'Unlock this offer by adding \$100 more',
        unlockThreshold: 100,
        isLocked: true,
        isVerified: false,
      ),
      CouponModel(
        id: 'c2',
        code: 'WELCOME24',
        title: 'Up to \$50.00 cashback',
        unlockCondition: 'Just \$200 more to go',
        unlockThreshold: 200,
        isLocked: true,
        isVerified: false,
      ),
      CouponModel(
        id: 'c3',
        code: 'NEWPATIENT',
        title: 'Get 25% OFF',
        unlockCondition: 'Unlock this offer by adding \$100 more',
        unlockThreshold: 100,
        isLocked: true,
        isVerified: false,
      ),
      CouponModel(
        id: 'c4',
        code: 'HEALTHFIRST',
        title: 'Get 20% OFF',
        unlockCondition: 'Unlock this offer by adding \$100 more',
        unlockThreshold: 100,
        isLocked: true,
        isVerified: false,
      ),
    ];
  }
}
