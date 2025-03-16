// lib/features/auth/presentation/viewmodels/auth_viewmodel.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../domain/repository/auth_repository.dart';

class AuthViewModel with ChangeNotifier {
  final AuthRepository authRepository;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AuthViewModel({required this.authRepository}) {
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _user = UserModel(email: firebaseUser.email ?? '', password: '');
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password, String firstName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      UserModel userModel = UserModel(email: email, password: password);
      _user = await authRepository.signUp(userModel);
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(firstName); // Update display name
        await FirebaseDatabase.instance
            .ref('users/${firebaseUser.uid}')
            .set({'firstName': firstName, 'email': email}); // Save to Realtime Database
      }
    } catch (e) {
      _errorMessage = e.toString();
      _user = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      UserModel userModel = UserModel(email: email, password: password);
      _user = await authRepository.signIn(userModel);
    } catch (e) {
      _errorMessage = e.toString();
      _user = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await authRepository.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}