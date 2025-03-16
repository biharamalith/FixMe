// lib/features/auth/presentation/views/notification_screen.dart
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
           icon: Image.asset(
           'assets/Doorbell.png', 
            width: 24, 
            height: 24,
     ),
  onPressed: () {
    Navigator.pop(context);
  },
),
      ),
      body: const Center(
        child: Text('No notifications yet'),
      ),
    );
  }
}