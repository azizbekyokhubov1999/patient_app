import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/mock_data.dart';
import '../../domain/repositories/coupons_repository.dart';
import 'coupons_state.dart';

class CouponsCubit extends Cubit<CouponsState> {
  CouponsCubit({
    required CouponsRepository couponsRepository,
    FirebaseAuth? auth,
  })  : _couponsRepository = couponsRepository,
        _auth = auth ?? FirebaseAuth.instance,
        super(const CouponsInitial());

  final CouponsRepository _couponsRepository;
  final FirebaseAuth _auth;

  Future<void> loadCoupons() async {
    emit(const CouponsLoading());

    if (kUseProfileMockData) {
      emit(CouponsLoaded(mockCouponsWithWalletBalance()));
      return;
    }

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(const CouponsError('No signed-in user'));
        return;
      }

      final coupons = await _couponsRepository.loadCoupons(userId: uid);
      emit(CouponsLoaded(coupons));
    } catch (e, st) {
      developer.log('loadCoupons error', error: e, stackTrace: st);
      emit(CouponsError(e.toString()));
    }
  }
}
