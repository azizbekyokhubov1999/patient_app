class UserModel {
  const UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.profilePictureUrl,
  });

  final String name;
  final String email;
  final String phone;
  final String gender;
  final String profilePictureUrl;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      profilePictureUrl: map['profilePictureUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? profilePictureUrl,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
