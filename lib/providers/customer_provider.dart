import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/firebase_service.dart';

class CustomerProvider extends ChangeNotifier {
  final FirebaseService _svc = FirebaseService();
  List<Customer> customers = [];
  bool isLoading = false;

  CustomerProvider() {
    load();
  }

  void load() {
    isLoading = true;
    notifyListeners();
    _svc.streamCustomers().listen((list) {
      customers = list;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addCustomer(Customer c) async {
    await _svc.addCustomer(c);
  }
}
