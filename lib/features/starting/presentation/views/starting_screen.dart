import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/starting_viewmodel.dart';

class StartingScreen extends StatelessWidget {
  const StartingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final startingViewModel = Provider.of<StartingViewModel>(context, listen: false);

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255), // Yellow background from Figma
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/plumber-drowning-himself.jpg', // Ensure correct path
                width: 350, // Adjust size if needed
                height: 350,
                fit: BoxFit.contain,
              ),
             
              const SizedBox(height: 20),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'FixMe - Find the best solution',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => startingViewModel.navigateToSignIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700), // Match Figma button color
                  foregroundColor: Colors.black,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}