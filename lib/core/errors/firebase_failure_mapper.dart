import 'package:firebase_auth/firebase_auth.dart';

import 'failures.dart';

/// Maps Firebase exceptions to domain [Failure] types.
abstract final class FirebaseFailureMapper {
  FirebaseFailureMapper._();

  static Failure map(Object error) {
    if (error is FirebaseAuthException) {
      return AuthFailure(_authMessage(error));
    }
    if (error is FirebaseException) {
      return ServerFailure(
        error.message ?? 'A server error occurred. Please try again.',
      );
    }
    return ServerFailure(error.toString());
  }

  static String _authMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'The email address is not valid.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No account found for this email.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'email-already-in-use' => 'An account already exists for this email.',
      'weak-password' => 'Password is too weak. Use at least 6 characters.',
      'operation-not-allowed' => 'Email/password sign-in is not enabled.',
      'too-many-requests' =>
        'Too many attempts. Please wait and try again later.',
      'network-request-failed' =>
        'Network error. Check your connection and try again.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }
}
