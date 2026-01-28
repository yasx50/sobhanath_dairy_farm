import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarScreen extends StatefulWidget {
  final String customerName;
  final String phoneNumber; // Add phone number
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

  @override
  void initState() {
    super.initState();
    _fetchMonthData();
  }

  Future<void> _fetchMonthData() async {
    setState(() => isLoading = true);
    try {
      final now = DateTime.now();
      final response = await http.get(
        Uri.parse('http://192.168.0.100:5000/milk-entry//${widget.phoneNumber}/milk-records/${now.year}/${now.month}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Parse and populate milkEntries from backend
        setState(() {
          totalBill = data['currentMonthAmount'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
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
          title: Text('Entry for ${day} ${DateFormat.MMM().format(DateTime.now())}'),
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
                    prefixIcon: Icon(Icons.local_drink),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fat Content (%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.opacity),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price per Liter (₹)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedShift,
                  decoration: const InputDecoration(
                    labelText: 'Shift',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
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
                  };
                });

                await _saveToBackend(day, quantity, fatContent, pricePerLiter, totalAmount, selectedShift);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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

      final response = await http.post(
        Uri.parse('http://192.168.0.100:5000/milk-entry/'),
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
          const SnackBar(content: Text('Saved successfully!'), backgroundColor: Colors.green),
        );
        _calculateBill();
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customerName),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_drink, size: 50, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text(
                    "Sobhnath Dairy",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.phoneNumber,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text("Orders"),
              onTap: () {},
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.shade50,
                  child: Text(
                    DateFormat.yMMMM().format(now),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

                      return InkWell(
                        onTap: () => _showEntryDialog(day),
                        child: Container(
                          decoration: BoxDecoration(
                            color: hasEntry ? Colors.green : Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              day.toString(),
                              style: TextStyle(
                                color: hasEntry ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Total Bill: ₹${totalBill.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculateBill,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Text('Calculate Bill', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}