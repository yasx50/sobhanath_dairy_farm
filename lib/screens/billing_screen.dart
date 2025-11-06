import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import 'package:image_picker/image_picker.dart';

class BillingScreen extends StatefulWidget {
  final String customerId;
  const BillingScreen({super.key, required this.customerId});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final FirebaseService _svc = FirebaseService();
  final StorageService _storage = StorageService();
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  double _ratePerLiter = 50; // default rate, change as needed
  bool _isGenerating = false;
  List<Map<String, dynamic>> _bills = [];

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  void _loadBills() async {
    final list = await _svc.getBillsForCustomer(widget.customerId);
    setState(() => _bills = list);
  }

  Future<void> _generateBill() async {
    setState(() => _isGenerating = true);
    final start = DateTime(_selectedYear, _selectedMonth, 1);
    final end = DateTime(_selectedYear, _selectedMonth + 1, 0, 23, 59, 59);
    final entries = await _svc.getEntriesForCustomerBetween(widget.customerId, start, end);
    double total = 0;
    for (var e in entries) total += e.quantity;
    final amount = total * _ratePerLiter;
    final monthKey = DateFormat('yyyy-MM').format(start);
    final data = {
      'customerId': widget.customerId,
      'month': monthKey,
      'totalQuantity': total,
      'amount': amount,
      'paid': false,
      'generatedAt': DateTime.now(),
    };
    await _svc.createBillFromMap(data);
    await _loadBills();
    setState(() => _isGenerating = false);
  }

  Future<void> _uploadPayment(String billId) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    final url = await _storage.uploadPaymentScreenshot(billId, file);
    await _svc.updateBill(billId, {'paymentScreenshotUrl': url, 'paid': true});
    await _loadBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                DropdownButton<int>(
                  value: _selectedMonth,
                  items: List.generate(12, (i) => DropdownMenuItem(value: i+1, child: Text('${i+1}'))),
                  onChanged: (v) { if (v!=null) setState(()=>_selectedMonth=v); },
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _selectedYear,
                  items: List.generate(5, (i) => DropdownMenuItem(value: DateTime.now().year - i, child: Text('${DateTime.now().year - i}'))),
                  onChanged: (v) { if (v!=null) setState(()=>_selectedYear=v); },
                ),
                const SizedBox(width: 12),
                Expanded(child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Rate per liter'),
                  onChanged: (v) => setState(()=>_ratePerLiter = double.tryParse(v) ?? _ratePerLiter),
                )),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isGenerating ? null : _generateBill,
                  child: _isGenerating ? const CircularProgressIndicator(color: Colors.white) : const Text('Generate'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: _bills.map((b) {
                  final id = b['id'];
                  final month = b['month'];
                  final total = b['totalQuantity'];
                  final amount = b['amount'];
                  final paid = b['paid'] ?? false;
                  final screenshot = b['paymentScreenshotUrl'];
                  return Card(
                    child: ListTile(
                      title: Text('Month: $month'),
                      subtitle: Text('Qty: $total L — ₹ $amount\nPaid: ${paid ? "Yes" : "No"}'),
                      isThreeLine: true,
                      trailing: Column(
                        children: [
                          IconButton(icon: const Icon(Icons.upload_file), onPressed: () => _uploadPayment(id)),
                          if (screenshot != null) IconButton(icon: const Icon(Icons.open_in_new), onPressed: () {
                            // open image - simple approach
                            showDialog(context: context, builder: (_) => Dialog(
                              child: Image.network(screenshot),
                            ));
                          }),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
