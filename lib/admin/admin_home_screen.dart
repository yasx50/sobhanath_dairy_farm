import 'package:flutter/material.dart';
import '../auth/firebase_google_auth.dart';
import 'admin_login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final String dairyName;

  const AdminHomeScreen({super.key, required this.dairyName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dairyName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseGoogleAuth.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              }
            },
          )
        ],
      ),
      body: const Center(
        child: Text("Welcome to Admin Panel"),
      ),
    );
  }
}
