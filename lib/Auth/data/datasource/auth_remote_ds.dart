import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:notes_app/Auth/data/model/user_model.dart';
import '../../../core/error/exception.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({required String email, required String password});
  Future<UserModel> signIn({required String email, required String password});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({required this.firebaseAuth,required this.firestore});

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw AuthException('User creation failed');
      }

      // 🔹 Update display name

      await firebaseUser.updateDisplayName(email);
      await firebaseUser.verifyBeforeUpdateEmail(email);

      final user = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );

      await firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(user.toJson());

      if (credential.user == null) {
        throw const AuthException('Failed to create user');
      }

      return UserModel.fromJson(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleFirebaseAuthError(e));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Failed to sign in');
      }

      return UserModel.fromJson(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleFirebaseAuthError(e));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;
      return UserModel.fromJson(user);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      if (kDebugMode) {
        print("current user $user");
      }
      return UserModel.fromJson(user);
    });
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }
}