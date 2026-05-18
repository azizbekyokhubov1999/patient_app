import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    this.phone = '',
    this.countryCode = '+1',
    this.dateOfBirth = '',
    this.gender = 'Female',
  });

  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final String phone;
  final String countryCode;
  final String dateOfBirth;
  final String gender;

  factory UserModel.fromMap(Map<String, dynamic> map, {required String uid}) {
    return UserModel(
      uid: uid,
      displayName: map['displayName'] as String? ??
          map['name'] as String? ??
          'Patient',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ??
          map['profilePictureUrl'] as String? ??
          '',
      phone: map['phone'] as String? ?? '',
      countryCode: map['countryCode'] as String? ?? '+1',
      dateOfBirth: map['dateOfBirth'] as String? ?? '',
      gender: map['gender'] as String? ?? 'Female',
    );
  }

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return UserModel.fromMap(doc.data() ?? {}, uid: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'phone': phone,
      'countryCode': countryCode,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    };
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    String? phone,
    String? countryCode,
    String? dateOfBirth,
    String? gender,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }
}
