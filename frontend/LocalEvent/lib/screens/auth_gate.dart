import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../services/auth_storage.dart';
import '../utils/colors/app_colors.dart';
import 'login_screen.dart';
import 'main_navigation.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<UserSession?> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = AuthStorage().readSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserSession?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }

        final session = snapshot.data;

        if (session == null) {
          return const LoginScreen();
        }

        return MainNavigation(session: session);
      },
    );
  }
}