import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'widgets/loading_widget.dart';
import 'screens/signup_page.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ConstropediaApp());
}

class ConstropediaApp extends StatelessWidget {
  const ConstropediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Constropedia',
      theme: AppTheme.lightTheme,
      routes: {
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
      },
      home: const AuthGate(),
    );
  }
}

/// Decides which screen should be shown when the app starts.
/// FirebaseAuth automatically keeps track of the current authentication state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase is checking the current authentication state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(
            isFullScreen: true,
            message: 'Starting Constropedia...',
          );
        }

        // User is logged in.
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // User is not logged in.
        return const LoginPage();
      },
    );
  }
}