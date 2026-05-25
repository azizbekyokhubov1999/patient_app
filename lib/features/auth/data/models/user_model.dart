import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.walletBalance,
    super.phone,
    super.gender,
    super.photoUrl,
    super.countryCode,
    super.isProfileComplete,
  });

  factory UserModel.fromFirestore({
    required String uid,
    required String email,
    Map<String, dynamic>? data,
  }) {
    final map = data ?? {};
    final walletRaw = map['walletBalance'];
    var wallet = 0.0;
    if (walletRaw is num) {
      wallet = walletRaw.toDouble();
    }

    return UserModel(
      uid: uid,
      email: email,
      name: map['name'] as String? ??
          map['displayName'] as String? ??
          '',
      walletBalance: wallet,
      phone: map['phone'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ??
          map['profilePictureUrl'] as String? ??
          '',
      countryCode: map['countryCode'] as String? ?? '+1',
      isProfileComplete: map['isProfileComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'walletBalance': walletBalance,
      'phone': phone,
      'gender': gender,
      'photoUrl': photoUrl,
      'countryCode': countryCode,
      'isProfileComplete': isProfileComplete,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    double? walletBalance,
    String? phone,
    String? gender,
    String? photoUrl,
    String? countryCode,
    bool? isProfileComplete,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      walletBalance: walletBalance ?? this.walletBalance,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      countryCode: countryCode ?? this.countryCode,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
