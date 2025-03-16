// lib/app.dart

//import 'package:fixme_new/features/auth/presentation/views/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/splash/presentation/viewmodels/splash_viewmodel.dart';
import 'features/starting/presentation/viewmodels/starting_viewmodel.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/auth/data/repository/auth_repository_impl.dart' as data;
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/splash/presentation/views/splash_screen.dart';
import 'features/starting/presentation/views/starting_screen.dart';
import 'features/auth/presentation/views/sign_in_screen.dart';
import 'features/auth/presentation/views/sign_up_screen.dart';
import 'features/auth/presentation/views/home_screen.dart';
import 'features/auth/presentation/views/notification_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide AuthRepository
        Provider<AuthRepository>(
          create: (_) => data.AuthRepositoryImpl(),
        ),
        // Provide SplashViewModel and StartingViewModel
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => StartingViewModel()),
        // Provide AuthViewModel with AuthRepository
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Service Booking App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/starting': (context) => const StartingScreen(),
          '/sign-in': (context) => const SignInScreen(),
          '/sign-up': (context) => const SignUpScreen(),
          '/home': (context) => HomeScreen(),
          '/notification': (context) => const NotificationScreen(),
        },
      ),
    );
  }
}