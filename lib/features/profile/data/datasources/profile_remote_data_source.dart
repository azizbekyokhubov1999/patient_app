import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel?> getUserProfile(String uid);

  Future<UserModel> saveUserProfile(UserModel user);

  Future<void> updatePhotoUrl({
    required String uid,
    required String photoUrl,
  });

  Future<void> signOut();

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteUserAccount({
    required String confirmationPassword,
  });

  Future<bool> getNotificationsEnabled(String uid);

  Future<void> setNotificationsEnabled({
    required String uid,
    required bool enabled,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null || firebaseUser.uid != uid) return null;

      return UserModel(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? 'Patient',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL ?? '',
      );
    }

    return UserModel.fromFirestore(doc);
  }

  @override
  Future<UserModel> saveUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(
      {
        ...user.toMap(),
        'isProfileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    return user;
  }

  @override
  Future<void> updatePhotoUrl({
    required String uid,
    required String photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> deleteUserAccount({
    required String confirmationPassword,
  }) async {
    final user = _auth.currentUser;
    final uid = user?.uid;
    final email = user?.email;

    if (user == null || uid == null || email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: confirmationPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await _firestore.collection('users').doc(uid).delete();
    await user.delete();
  }

  @override
  Future<bool> getNotificationsEnabled(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final value = doc.data()?['notificationsEnabled'];
    if (value is bool) return value;
    return true;
  }

  @override
  Future<void> setNotificationsEnabled({
    required String uid,
    required bool enabled,
  }) async {
    await _firestore.collection('users').doc(uid).set(
      {'notificationsEnabled': enabled},
      SetOptions(merge: true),
    );
  }
}
