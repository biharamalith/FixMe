// lib/features/starting/presentation/viewmodels/starting_viewmodel.dart

import 'package:flutter/material.dart';

class StartingViewModel with ChangeNotifier {
  void navigateToSignIn(BuildContext context) {
    // Navigate to the sign-in screen
    Navigator.pushNamed(context, '/sign-in');
  }
}