import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AppUserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Future<AppUserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      return null;
    }

    return AppUserModel(
      id: user.uid,
      email: user.email!,
    );
  }
}
