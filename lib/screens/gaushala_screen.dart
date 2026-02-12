import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GaushalaScreen extends StatefulWidget {
  const GaushalaScreen({super.key});

  @override
  State<GaushalaScreen> createState() => _GaushalaScreenState();
}

class _GaushalaScreenState extends State<GaushalaScreen> {
  List<ApplicationMeta>? _apps;
  bool _isLoading = false;
  String? _errorMessage;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _getApps();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment Successful!\nPayment ID: ${response.paymentId}"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
    print("Payment Success: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment Failed!\nError: ${response.message}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
    print("Payment Error: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("External Wallet Selected: ${response.walletName}"),
          backgroundColor: Colors.blue,
        ),
      );
    }
    print("External Wallet: ${response.walletName}");
  }

  Future<void> _getApps() async {
    try {
      // Try to get all UPI apps
      final apps = await UpiPay.getInstalledUpiApplications(
        statusType: UpiApplicationDiscoveryAppStatusType.all,
      );
      
      setState(() {
        _apps = apps;
        if (apps.isEmpty) {
          _errorMessage = "No UPI apps detected. Please check AndroidManifest.xml";
        }
      });

      // Debug: Print app count
      print("Found ${apps.length} UPI apps");
      for (var app in apps) {
        print("App: ${app.upiApplication.getAppName()}");
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
      });
      print("Error fetching UPI apps: $e");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching UPI apps: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _payWithRazorpay(String amount) async {
    try {
      var options = {
        'key': dotenv.env['RAZORPAY_KEY_ID'] ?? 'rzp_test_ofe2WQK1ymU8N1',
        'amount': (int.parse(amount) * 100).toString(), // Amount in paise
        'name': 'Sobhnath Gaushala',
        'description': 'Donation to Gaushala',
        'prefill': {
          'contact': '9000090000', // 🔴 OPTIONAL: Pre-filled phone number
          'email': 'donor@gaushala.com', // 🔴 OPTIONAL: Pre-filled email
        },
        'notes': {
          'purpose': 'Gaushala Donation',
          'timestamp': DateTime.now().toString(),
        },
        'timeout': 300, // 5 minutes timeout
      };

      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error initiating payment: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("Razorpay Error: $e");
    }
  }

  Future<void> _pay(String amount, ApplicationMeta app) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactionRef = Random.secure().nextInt(1 << 32).toString();

      final response = await UpiPay.initiateTransaction(
        amount: amount,
        app: app.upiApplication,
        receiverName: 'Sobhnath Gaushala',
        receiverUpiAddress: 'huyashbhai-1@okicici', // 🔴 CHANGE THIS
        transactionRef: transactionRef,
        transactionNote: 'Gaushala Donation',
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaction completed! Check your payment app for status."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Transaction Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUpiApps(String amount) {
    // Better check with debug info
    if (_apps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Still loading UPI apps. Please wait..."),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    if (_apps!.isEmpty) {
      // Show detailed error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("No UPI Apps Found"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Unable to detect UPI apps on your device."),
              const SizedBox(height: 12),
              const Text("Solutions:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("1. Make sure you have Google Pay or PhonePe installed"),
              const SizedBox(height: 4),
              const Text("2. Restart the app after installing UPI apps"),
              const SizedBox(height: 4),
              const Text("3. Check if AndroidManifest.xml has <queries> tag"),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text("Error: $_errorMessage", style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _getApps(); // Retry
              },
              child: const Text("Retry"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Choose Payment App (${_apps!.length} found)",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
                children: _apps!.map((app) {
                  return InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await _pay(amount, app);
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          app.iconImage(48),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              app.upiApplication.getAppName(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showDonationDialog(BuildContext context) {
    final amountController = TextEditingController(text: "500");
    String selectedAmount = "500";
    String selectedPaymentMethod = "razorpay"; // Default to Razorpay

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.favorite, color: Colors.red),
              SizedBox(width: 8),
              Text("Donate to Gaushala"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select or enter donation amount:",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ["100", "500", "1000", "2000"].map((amount) {
                    return ChoiceChip(
                      label: Text("₹$amount"),
                      selected: selectedAmount == amount,
                      selectedColor: Colors.green.shade100,
                      onSelected: (_) {
                        setDialogState(() {
                          selectedAmount = amount;
                          amountController.text = amount;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Custom Amount (₹)",
                    border: OutlineInputBorder(),
                    prefixText: "₹ ",
                  ),
                  onChanged: (v) {
                    setDialogState(() {
                      selectedAmount = v;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Choose Payment Method:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.payment, color: Colors.blue, size: 24),
                      SizedBox(width: 12),
                      Text("Razorpay"),
                    ],
                  ),
                  subtitle: const Text("Credit/Debit Card, UPI, Wallets"),
                  value: "razorpay",
                  groupValue: selectedPaymentMethod,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedPaymentMethod = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.mobile_screen_share, color: Colors.purple, size: 24),
                      SizedBox(width: 12),
                      Text("UPI"),
                    ],
                  ),
                  subtitle: const Text("Google Pay, PhonePe, etc."),
                  value: "upi",
                  groupValue: selectedPaymentMethod,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedPaymentMethod = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(selectedAmount) ?? 0;
                if (amount > 0) {
                  Navigator.pop(context);
                  if (selectedPaymentMethod == "razorpay") {
                    _payWithRazorpay(selectedAmount);
                  } else {
                    _showUpiApps(selectedAmount);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid amount"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Proceed to Pay"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCowCard({
    required String name,
    required String breed,
    required String age,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 50, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "$breed • Age: $age",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gaushala", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.green.shade700],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.pets, size: 60, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      "Sobhnath Gaushala",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Support our sacred cows",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    _buildCowCard(
                      name: "Ganga",
                      breed: "Gir",
                      age: "5 years",
                      description: "Gentle and loving cow. Known for high-quality milk.",
                      icon: Icons.pets,
                      color: Colors.brown,
                    ),
                    _buildCowCard(
                      name: "Lakshmi",
                      breed: "Sahiwal",
                      age: "3 years",
                      description: "Friendly and energetic. Loves to interact with visitors.",
                      icon: Icons.favorite,
                      color: Colors.pink,
                    ),
                    _buildCowCard(
                      name: "Kamadhenu",
                      breed: "Red Sindhi",
                      age: "7 years",
                      description: "Wise and peaceful. The oldest member of our family.",
                      icon: Icons.spa,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _showDonationDialog(context),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.volunteer_activism),
              label: Text(
                _isLoading ? "Processing..." : "Donate Now",
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}