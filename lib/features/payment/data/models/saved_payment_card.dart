class SavedPaymentCard {
  const SavedPaymentCard({
    required this.id,
    required this.cardHolderName,
    required this.maskedNumber,
    required this.lastFour,
  });

  final String id;
  final String cardHolderName;
  final String maskedNumber;
  final String lastFour;

  factory SavedPaymentCard.fromMap(Map<String, dynamic> map, String id) {
    final number = map['cardNumber'] as String? ?? '';
    final digits = number.replaceAll(RegExp(r'\D'), '');
    final lastFour =
        digits.length >= 4 ? digits.substring(digits.length - 4) : '0000';

    return SavedPaymentCard(
      id: id,
      cardHolderName: map['cardHolderName'] as String? ?? '',
      maskedNumber: '**** **** **** $lastFour',
      lastFour: lastFour,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardHolderName': cardHolderName,
      'cardNumber': maskedNumber,
      'lastFour': lastFour,
    };
  }
}
