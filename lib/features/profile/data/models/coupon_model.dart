import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  const CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.unlockCondition,
    required this.unlockThreshold,
    required this.isLocked,
    required this.isVerified,
  });

  final String id;
  final String code;
  final String title;
  final String unlockCondition;
  final double unlockThreshold;
  final bool isLocked;
  final bool isVerified;

  factory CouponModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return CouponModel.fromMap(doc.data() ?? {}, doc.id);
  }

  factory CouponModel.fromMap(Map<String, dynamic> map, String id) {
    return CouponModel(
      id: id,
      code: map['code'] as String? ?? '',
      title: map['title'] as String? ?? '',
      unlockCondition: map['unlockCondition'] as String? ?? '',
      unlockThreshold: (map['unlockThreshold'] as num?)?.toDouble() ?? 0,
      isLocked: map['isLocked'] as bool? ?? true,
      isVerified: map['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'unlockCondition': unlockCondition,
      'unlockThreshold': unlockThreshold,
      'isLocked': isLocked,
      'isVerified': isVerified,
    };
  }

  /// Applies wallet-balance unlock rules on top of Firestore fields.
  CouponModel withWalletBalance(double walletBalance) {
    final unlocked = walletBalance >= unlockThreshold;
    return copyWith(
      isLocked: !unlocked,
      isVerified: unlocked,
    );
  }

  CouponModel copyWith({
    String? id,
    String? code,
    String? title,
    String? unlockCondition,
    double? unlockThreshold,
    bool? isLocked,
    bool? isVerified,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      unlockCondition: unlockCondition ?? this.unlockCondition,
      unlockThreshold: unlockThreshold ?? this.unlockThreshold,
      isLocked: isLocked ?? this.isLocked,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
