import 'package:flutter/material.dart';
import '../auth/firebase_google_auth.dart';
import 'admin_home_screen.dart';
import 'admin_setup_screen.dart';
import '../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final user = await FirebaseGoogleAuth.signInWithGoogle();

            if (user != null && context.mounted) {
              _checkDairyAndNavigate(context, user);
            }
          },
          child: const Text("Continue with Google"),
        ),
      ),
    );
  }

  Future<void> _checkDairyAndNavigate(BuildContext context, User user) async {
    final apiService = ApiService();
    final dairies = await apiService.getDairyByOwner(user.uid);

    if (context.mounted) {
      if (dairies.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminSetupScreen()),
        );
      } else {
        // Assuming first dairy for now
        final dairy = dairies.first;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHomeScreen(dairyName: dairy['name'] ?? 'My Dairy'),
          ),
        );
      }
    }
  }
}

