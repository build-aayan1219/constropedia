import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/signup_page.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'theme/app_theme.dart';
import 'widgets/app_ui.dart';

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
      theme: AppTheme.light(),
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
///
/// FirebaseAuth automatically keeps track of the current
/// authentication state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: AppLoadingState(message: 'Preparing Constropedia...'),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginPage();
      },
    );
  }
}
