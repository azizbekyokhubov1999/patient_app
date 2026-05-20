import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/mock_data.dart';
import '../../data/models/coupon_model.dart';
import 'coupons_state.dart';

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

    if (kUseProfileMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      emit(CouponsLoaded(mockCouponsWithWalletBalance()));
      return;
    }

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(const CouponsError('No signed-in user'));
        return;
      }

      final walletBalance = await _fetchWalletBalance(uid);

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
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    return (data['balance'] as num?)?.toDouble() ??
        (data['wallet_balance'] as num?)?.toDouble() ??
        0;
  }
}
