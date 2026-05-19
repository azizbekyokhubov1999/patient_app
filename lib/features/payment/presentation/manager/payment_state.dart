import '../../data/models/saved_payment_card.dart';

abstract final class PaymentStatus {
  static const String initial = 'initial';
  static const String loading = 'loading';
  static const String loaded = 'loaded';
  static const String failure = 'failure';
}

/// Known non-card payment method ids.
abstract final class PaymentMethodIds {
  static const String paypal = 'paypal';
  static const String applePay = 'apple_pay';
  static const String googlePay = 'google_pay';

  static String card(String cardId) => 'card:$cardId';
}

class PaymentState {
  const PaymentState({
    this.status = PaymentStatus.initial,
    this.cards = const [],
    this.defaultMethodId,
    this.walletId,
    this.errorMessage,
  });

  final String status;
  final List<SavedPaymentCard> cards;
  final String? defaultMethodId;
  final String? walletId;
  final String? errorMessage;

  bool get isLoading => status == PaymentStatus.loading;
  bool get isLoaded => status == PaymentStatus.loaded;
  bool get isFailure => status == PaymentStatus.failure;

  PaymentState copyWith({
    String? status,
    List<SavedPaymentCard>? cards,
    Object? defaultMethodId = _sentinel,
    Object? walletId = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return PaymentState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      defaultMethodId: identical(defaultMethodId, _sentinel)
          ? this.defaultMethodId
          : defaultMethodId as String?,
      walletId:
          identical(walletId, _sentinel) ? this.walletId : walletId as String?,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();
}
