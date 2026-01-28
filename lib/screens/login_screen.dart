import 'package:flutter/material.dart';
import 'calendar_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _otpController = TextEditingController();

  bool otpSent = false;

  void verifyOtp() {
    if (_otpController.text == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CalendarScreen(
            customerName: _nameController.text,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Mobile Number"),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
            const SizedBox(height: 20),
            if (!otpSent)
              ElevatedButton(
                onPressed: () {
                  setState(() => otpSent = true);
                },
                child: const Text("Send OTP"),
              ),
            if (otpSent) ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter OTP (1234)"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: verifyOtp,
                child: const Text("Verify & Continue"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
