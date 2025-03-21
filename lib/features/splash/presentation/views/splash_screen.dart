import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/splash_viewmodel.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final splashViewModel = Provider.of<SplashViewModel>(context, listen: false);

   
    WidgetsBinding.instance.addPostFrameCallback((_) {
      splashViewModel.navigateToStartingScreen(context);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFE730), 
      body: Center(
        child: Image.asset(
          'assets/fixme-new.jpg', 
          width: 150, 
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
