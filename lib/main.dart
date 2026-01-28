import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SobhnathDairyApp());
}

class SobhnathDairyApp extends StatelessWidget {
  const SobhnathDairyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sobhnath Dairy',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}
