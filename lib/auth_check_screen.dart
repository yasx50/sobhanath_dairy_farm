import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'admin_home_screen.dart';
import 'admin_login_screen.dart';
import 'admin_setup_screen.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } else {
      final apiService = ApiService();
      // Allow UI to build first
      await Future.delayed(Duration.zero);
      
      try {
        final dairies = await apiService.getDairyByOwner(user.uid);
        if (mounted) {
          if (dairies.isEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminSetupScreen()),
            );
          } else {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AdminHomeScreen(dairyName: dairies[0]['name'] ?? 'My Dairy'),
              ),
            );
          }
        }
      } catch (e) {
         // Fallback or error handling
         if(mounted) {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
