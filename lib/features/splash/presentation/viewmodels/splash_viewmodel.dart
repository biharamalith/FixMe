import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  void navigateToStartingScreen(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/starting');
    });
  }
}