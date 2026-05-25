import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> authStateChanges();

  Future<UserModel?> getCurrentUser();

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<UserModel> completeProfile({
    required String name,
    required String phone,
    required String gender,
    String countryCode = '+1',
  });

  Future<void> updateUserLocation({
    required String uid,
    required double latitude,
    required double longitude,
  });

  Future<void> updateNotificationPreference({
    required String uid,
    required bool notificationsEnabled,
  });

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<UserModel?> _userFromFirebaseUser(User? user) async {
    if (user == null || user.email == null) return null;
    final doc = await _usersCollection.doc(user.uid).get();
    return UserModel.fromFirestore(
      uid: user.uid,
      email: user.email!,
      data: doc.data(),
    );
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap(_userFromFirebaseUser);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _userFromFirebaseUser(_firebaseAuth.currentUser);
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final profile = await _userFromFirebaseUser(user);
    return profile ??
        UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email!,
        );
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(code: 'operation-not-allowed');
    }

    final trimmedName = name.trim();
    await user.updateDisplayName(trimmedName);

    final userModel = UserModel(
      uid: user.uid,
      name: trimmedName,
      email: user.email!,
      walletBalance: 0,
      isProfileComplete: false,
    );

    await _usersCollection.doc(user.uid).set({
      'uid': user.uid,
      'name': trimmedName,
      'email': user.email!,
      'walletBalance': 0.0,
      'createdAt': Timestamp.now(),
      'isProfileComplete': false,
    });

    try {
      await user.sendEmailVerification();
    } catch (_) {
      // Optional for onboarding UI.
    }

    return userModel;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<UserModel> completeProfile({
    required String name,
    required String phone,
    required String gender,
    String countryCode = '+1',
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final trimmedName = name.trim();
    await user.updateDisplayName(trimmedName);

    final existing = await _usersCollection.doc(user.uid).get();
    final walletRaw = existing.data()?['walletBalance'];
    final wallet = walletRaw is num ? walletRaw.toDouble() : 0.0;

    final profile = UserModel(
      uid: user.uid,
      name: trimmedName,
      email: user.email!,
      walletBalance: wallet,
      phone: phone.trim(),
      gender: gender,
      countryCode: countryCode,
      isProfileComplete: true,
    );

    await _usersCollection.doc(user.uid).set(
      {
        ...profile.toFirestoreMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return profile;
  }

  @override
  Future<void> updateUserLocation({
    required String uid,
    required double latitude,
    required double longitude,
  }) async {
    await _usersCollection.doc(uid).set(
      {
        'latitude': latitude,
        'longitude': longitude,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> updateNotificationPreference({
    required String uid,
    required bool notificationsEnabled,
  }) async {
    await _usersCollection.doc(uid).set(
      {
        'notificationsEnabled': notificationsEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
