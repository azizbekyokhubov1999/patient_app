import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../booking/domain/entities/card_model.dart';
import '../../data/models/saved_payment_card.dart';
import 'payment_state.dart';

const bool _kPresentationMockPayment = true;

List<SavedPaymentCard> _mockCards() {
  return const [
    SavedPaymentCard(
      id: 'card-1',
      cardHolderName: 'Jennifer Aaker',
      maskedNumber: '**** **** **** 8047',
      lastFour: '8047',
    ),
  ];
}

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const PaymentState());

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> loadPaymentMethods() async {
    emit(state.copyWith(status: PaymentStatus.loading, errorMessage: null));

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: 'No signed-in user',
        ),
      );
      return;
    }

    try {
      if (_kPresentationMockPayment) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        emit(
          state.copyWith(
            status: PaymentStatus.loaded,
            cards: _mockCards(),
            defaultMethodId: PaymentMethodIds.paypal,
            walletId: 'WLT-${uid.substring(0, 6).toUpperCase()}',
          ),
        );
        return;
      }

      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};

      final cardsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cards')
          .orderBy('createdAt', descending: true)
          .get();

      final cards = cardsSnapshot.docs
          .map((doc) => SavedPaymentCard.fromMap(doc.data(), doc.id))
          .toList();

      emit(
        state.copyWith(
          status: PaymentStatus.loaded,
          cards: cards,
          defaultMethodId: userData['defaultPaymentMethodId'] as String?,
          walletId: userData['walletId'] as String?,
        ),
      );
    } catch (e, st) {
      developer.log('loadPaymentMethods error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> setDefaultPaymentMethod(String methodId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    emit(state.copyWith(defaultMethodId: methodId));

    try {
      if (!_kPresentationMockPayment) {
        await _firestore.collection('users').doc(uid).set(
          {'defaultPaymentMethodId': methodId},
          SetOptions(merge: true),
        );
      }
    } catch (e, st) {
      developer.log('setDefaultPaymentMethod error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> addSavedCard(CardModel card) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final digits = card.cardNumber.replaceAll(RegExp(r'\D'), '');
    final lastFour =
        digits.length >= 4 ? digits.substring(digits.length - 4) : '0000';

    final saved = SavedPaymentCard(
      id: card.id,
      cardHolderName: card.cardHolderName,
      maskedNumber: '**** **** **** $lastFour',
      lastFour: lastFour,
    );

    try {
      if (!_kPresentationMockPayment) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('cards')
            .doc(card.id)
            .set({
          'cardHolderName': card.cardHolderName,
          'cardNumber': card.cardNumber,
          'expiryDate': card.expiryDate,
          'lastFour': lastFour,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final updatedCards = [saved, ...state.cards];
      emit(
        state.copyWith(
          cards: updatedCards,
          defaultMethodId: PaymentMethodIds.card(card.id),
          status: PaymentStatus.loaded,
        ),
      );

      await setDefaultPaymentMethod(PaymentMethodIds.card(card.id));
    } catch (e, st) {
      developer.log('addSavedCard error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
