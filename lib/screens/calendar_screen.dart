import 'profile_screen.dart';
import 'gaushala_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CalendarScreen extends StatefulWidget {
  final String customerName;
  final String phoneNumber;
  const CalendarScreen({
    super.key,
    required this.customerName,
    required this.phoneNumber,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final Map<int, Map<String, dynamic>> milkEntries = {};
  double totalBill = 0;
  bool isLoading = false;
  List<ApplicationMeta>? _upiApps;

  @override
  void initState() {
    super.initState();
    _fetchMonthData();
    _getUpiApps();
  }

  Future<void> _getUpiApps() async {
    try {
      _upiApps = await UpiPay.getInstalledUpiApplications(
        statusType: UpiApplicationDiscoveryAppStatusType.all,
      );
      setState(() {});
    } catch (e) {
      print('Error fetching UPI apps: $e');
    }
  }

  Future<void> _fetchMonthData() async {
    setState(() => isLoading = true);
    try {
      final now = DateTime.now();
      final backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';
      final response = await http.get(
        Uri.parse('$backendUrl/login?mobile_number=${widget.phoneNumber}'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final customer = data['customer'];
        final milkRecords = customer['milkRecords'];
        
        setState(() {
          totalBill = (milkRecords['currentMonthAmount'] ?? 0).toDouble();
          milkEntries.clear();
          
          // Parse entries from API
          if (milkRecords['years'] != null && milkRecords['years'].isNotEmpty) {
            final currentYear = milkRecords['years'].firstWhere(
              (year) => year['year'] == now.year,
              orElse: () => null,
            );
            
            if (currentYear != null && currentYear['months'] != null) {
              final currentMonth = currentYear['months'].firstWhere(
                (month) => month['month'] == now.month,
                orElse: () => null,
              );
              
              if (currentMonth != null && currentMonth['entries'] != null) {
                for (var entry in currentMonth['entries']) {
                  final date = DateTime.parse(entry['date']);
                  final day = date.day;
                  
                  milkEntries[day] = {
                    'quantity': (entry['quantity'] ?? 0).toDouble(),
                    'fatContent': (entry['fatContent'] ?? 0).toDouble(),
                    'pricePerLiter': (entry['pricePerLiter'] ?? 75).toDouble(),
                    'totalAmount': (entry['totalAmount'] ?? 0).toDouble(),
                    'shift': entry['shift'] ?? 'full-day',
                    'verified': entry['verified'] ?? false,
                  };
                }
              }
            }
          }
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showEntryDialog(int day) {
    final entry = milkEntries[day];
    final quantityController = TextEditingController(
      text: entry?['quantity']?.toString() ?? '0',
    );
    final fatController = TextEditingController(
      text: entry?['fatContent']?.toString() ?? '0',
    );
    final priceController = TextEditingController(
      text: entry?['pricePerLiter']?.toString() ?? '75',
    );
    String selectedShift = entry?['shift'] ?? 'full-day';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.local_drink, color: Colors.green),
              const SizedBox(width: 8),
              Text('Entry for ${day} ${DateFormat.MMM().format(DateTime.now())}'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity (Liters)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_drink, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fat Content (%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.opacity, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price per Liter (₹)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee, color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedShift,
                  decoration: const InputDecoration(
                    labelText: 'Shift',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time, color: Colors.purple),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'morning', child: Text('Morning')),
                    DropdownMenuItem(value: 'evening', child: Text('Evening')),
                    DropdownMenuItem(value: 'full-day', child: Text('Full Day')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedShift = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final quantity = double.tryParse(quantityController.text) ?? 0;
                final fatContent = double.tryParse(fatController.text) ?? 0;
                final pricePerLiter = double.tryParse(priceController.text) ?? 75;
                final totalAmount = quantity * pricePerLiter;

                setState(() {
                  milkEntries[day] = {
                    'quantity': quantity,
                    'fatContent': fatContent,
                    'pricePerLiter': pricePerLiter,
                    'totalAmount': totalAmount,
                    'shift': selectedShift,
                    'verified': false,
                  };
                });

                await _saveToBackend(day, quantity, fatContent, pricePerLiter, totalAmount, selectedShift);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToBackend(int day, double quantity, double fatContent, 
      double pricePerLiter, double totalAmount, String shift) async {
    try {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, day);
      final backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

      final response = await http.post(
        Uri.parse('$backendUrl/milk-entry/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': widget.phoneNumber,
          'date': date.toIso8601String(),
          'quantity': quantity,
          'fatContent': fatContent,
          'pricePerLiter': pricePerLiter,
          'totalAmount': totalAmount,
          'shift': shift,
          'year': now.year,
          'month': now.month,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh data to get updated entries
        await _fetchMonthData();
      } else {
        throw Exception('Failed to save');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _calculateBill() {
    double bill = 0;
    milkEntries.forEach((day, entry) {
      bill += entry['totalAmount'] ?? 0;
    });
    setState(() => totalBill = bill);
  }

  Future<void> _payViaUpi() async {
    if (_upiApps == null || _upiApps!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No UPI apps found. Please install a UPI app."),
          backgroundColor: Colors.orange,
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
              child: Column(
                children: [
                  const Text(
                    "Pay Bill via UPI",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Amount: ₹${totalBill.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
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
                children: _upiApps!.map((app) {
                  return InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await _initiatePayment(app);
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

  Future<void> _initiatePayment(ApplicationMeta app) async {
    try {
      final transactionRef = Random.secure().nextInt(1 << 32).toString();

      await UpiPay.initiateTransaction(
        amount: totalBill.toStringAsFixed(2),
        app: app.upiApplication,
        receiverName: 'Sobhnath Dairy Farm',
        receiverUpiAddress: 'sobhnath@okaxis', // 🔴 CHANGE THIS to your actual UPI ID
        transactionRef: transactionRef,
        transactionNote: 'Milk Bill Payment - ${widget.phoneNumber}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment initiated! Check your payment app for status."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customerName),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_drink, size: 60, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    "Sobhnath Dairy",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.phoneNumber,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green, size: 28),
              title: const Text("Profile", style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(phoneNumber: widget.phoneNumber),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets, color: Colors.green, size: 28),
              title: const Text("Gaushala", style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GaushalaScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.green, size: 28),
              title: const Text("Pay Bill", style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _payViaUpi();
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red, size: 28),
              title: const Text("Logout", style: TextStyle(fontSize: 16)),
              onTap: _logout,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade50, Colors.green.shade100],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat.yMMMM().format(now),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${milkEntries.length} entries this month",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      int day = index + 1;
                      bool hasEntry = milkEntries[day] != null && 
                          (milkEntries[day]!['quantity'] ?? 0) > 0;
                      
                      final entry = milkEntries[day];
                      final quantity = entry?['quantity'] ?? 0;

                      return InkWell(
                        onTap: () => _showEntryDialog(day),
                        child: Container(
                          decoration: BoxDecoration(
                            color: hasEntry ? Colors.green : Colors.white,
                            border: Border.all(
                              color: hasEntry ? Colors.green.shade700 : Colors.grey.shade300,
                              width: hasEntry ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: hasEntry
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day.toString(),
                                style: TextStyle(
                                  color: hasEntry ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (hasEntry) ...[
                                const SizedBox(height: 2),
                                Icon(
                                  Icons.local_drink,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                Text(
                                  '${quantity.toStringAsFixed(1)}L',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Bill:",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "₹${totalBill.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _calculateBill,
                              icon: const Icon(Icons.calculate),
                              label: const Text('Refresh Bill'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade100,
                                foregroundColor: Colors.green.shade900,
                                padding: const EdgeInsets.all(16),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: totalBill > 0 ? _payViaUpi : null,
                              icon: const Icon(Icons.payment),
                              label: const Text('Pay Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                                elevation: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}