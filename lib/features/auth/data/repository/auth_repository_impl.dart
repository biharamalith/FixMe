// lib/features/auth/data/repository/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repository/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserModel> signIn(UserModel user) async {
    try {
      UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      if (credential.user != null) {
        debugPrint('Sign-in successful for ${user.email}');
        return UserModel(email: credential.user!.email ?? '', password: '');
      } else {
        throw Exception('Sign-in failed: No user returned');
      }
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw Exception('Sign-in failed: $e');
    }
  }

  @override
  Future<UserModel> signUp(UserModel user) async {
    try {
      UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      if (credential.user != null) {
        debugPrint('Sign-up successful for ${user.email}');
        return UserModel(email: credential.user!.email ?? '', password: '');
      } else {
        throw Exception('Sign-up failed: No user returned');
      }
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw Exception('Sign-up failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      debugPrint('Sign-out successful');
    } catch (e) {
      throw Exception('Sign-out failed: $e');
    }
  }

  Exception _mapFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('This email is already registered.');
      case 'invalid-email':
        return Exception('Invalid email format.');
      case 'weak-password':
        return Exception('Password must be at least 6 characters.');
      case 'user-not-found':
      case 'wrong-password':
        return Exception('Invalid email or password.');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
}