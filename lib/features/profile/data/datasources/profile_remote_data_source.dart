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
}
