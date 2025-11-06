import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isLoading = true;

  AuthProvider() {
    _auth.authStateChanges().listen((u) {
      user = u;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    isLoading = true; notifyListeners();
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    isLoading = false; notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    isLoading = true; notifyListeners();
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
    isLoading = false; notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
