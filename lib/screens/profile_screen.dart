import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final String phoneNumber;

  const ProfileScreen({super.key, required this.phoneNumber});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  Map<String, dynamic>? customerData;
  String? errorMessage;

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    _fetchCustomerProfile();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (res) {
      _showSnack('Payment Success!', Colors.green);
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (res) {
      _showSnack('Payment Failed!', Colors.red);
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Future<void> _fetchCustomerProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final backendUrl =
          dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';
      final response = await http.get(
        Uri.parse('$backendUrl/customer/${widget.phoneNumber}'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          customerData = jsonResponse['customer'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load profile';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // ================= PAYMENT =================
  void _payAmount() {
    final amount =
        (customerData?['milkRecords']?['currentMonthAmount'] ?? 0)
            .toDouble();

    if (amount <= 0) {
      _showSnack('No pending bill', Colors.orange);
      return;
    }

    final key = dotenv.env['RAZORPAY_KEY_ID'] ?? '';

    final options = {
      'key': key,
      'amount': (amount * 100).toInt(),
      'name': 'Sobhnath Dairy Farm',
      'description': 'Milk Bill Payment',
      'prefill': {
        'contact': widget.phoneNumber,
        'name': customerData?['name'] ?? 'Customer'
      },
      'theme': {'color': '#2E7D32'}
    };

    _razorpay.open(options);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Not provided';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return 'Not provided';
    }
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 30),
        title: Text(title,
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
        subtitle: Text(value,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingAmount =
        (customerData?['milkRecords']?['currentMonthAmount'] ?? 0)
            .toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: pendingAmount > 0
          ? FloatingActionButton.extended(
              onPressed: _payAmount,
              backgroundColor: Colors.green,
              icon: const Icon(Icons.payment),
              label: Text('Pay ₹${pendingAmount.toStringAsFixed(0)}'),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : RefreshIndicator(
                  onRefresh: _fetchCustomerProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            customerData?['name'] ?? 'Customer',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),

                        _buildSectionTitle('Current Bill'),
                        _buildInfoCard(
                          'Pending Amount',
                          '₹${pendingAmount.toStringAsFixed(2)}',
                          Icons.currency_rupee,
                        ),

                        _buildSectionTitle('Account Info'),
                        _buildInfoCard(
                          'Member Since',
                          _formatDate(customerData?['createdAt']),
                          Icons.calendar_today,
                        ),
                        _buildInfoCard(
                          'Last Updated',
                          _formatDate(customerData?['updatedAt']),
                          Icons.update,
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
    );
  }
}
