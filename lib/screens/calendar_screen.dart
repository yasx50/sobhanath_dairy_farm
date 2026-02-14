import 'profile_screen.dart';
import 'gaushala_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:razorpay_flutter/razorpay_flutter.dart';
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
  double currentMonthAmount = 0; // Track the current month amount from API
  bool isLoading = false;
  late Razorpay _razorpay;

  // ─── Colour legend ───────────────────────────────────────────────
  static const Color _customerTookColor = Color(0xFF1B5E20);   // Dark green - customer took milk
  static const Color _entryColor = Color(0xFF1565C0);           // Blue - entry recorded only
  static const Color _todayColor = Color(0xFFE65100);           // Orange - today highlight
  static const Color _emptyColor = Color(0xFFFAFAFA);           // Light gray - no entry

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    _fetchMonthData();
  }

  // ─── Razorpay setup ──────────────────────────────────────────────
  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    _showSnack('✅ Payment successful! ID: ${response.paymentId}', Colors.green);
  }

  void _onPaymentError(PaymentFailureResponse response) {
    _showSnack('❌ Payment failed: ${response.message}', Colors.red);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    _showSnack('💳 External wallet: ${response.walletName}', Colors.blue);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────
  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  String get _backendUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // Helper function to safely convert dynamic to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Helper function to safely convert dynamic to int
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // ─── Fetch data from updated API ──────────────────────────────────
  Future<void> _fetchMonthData() async {
    setState(() => isLoading = true);

    try {
      final now = DateTime.now();

      // Updated API endpoint to use /customer/{phoneNumber}
      final response = await http.get(
        Uri.parse('$_backendUrl/customer/${widget.phoneNumber}'),
      );

      if (response.statusCode != 200) {
        throw Exception('Server ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final customer = data['customer'];
      final milkRecords = customer['milkRecords'];

      setState(() {
        currentMonthAmount = _toDouble(milkRecords['currentMonthAmount']);
        totalBill = currentMonthAmount;

        milkEntries.clear();

        // ---- SAFE LOOP LOGIC - Extract from years/months/entries ----
        final years = milkRecords['years'] as List? ?? [];

        for (var yearObj in years) {
          final yearValue = _toInt(yearObj['year']);
          if (yearValue != now.year) continue;

          final months = yearObj['months'] as List? ?? [];

          for (var monthObj in months) {
            final monthValue = _toInt(monthObj['month']);
            if (monthValue != now.month) continue;

            final entries = monthObj['entries'] as List? ?? [];

            for (var entry in entries) {
              try {
                // Parse the ISO 8601 date string from API
                final dateString = entry['date'] as String?;
                if (dateString == null || dateString.isEmpty) continue;

                final date = DateTime.parse(dateString);
                final day = date.day;

                final qty = _toDouble(entry['quantity']);
                final totalAmt = _toDouble(entry['totalAmount']);

                // Check if customer took the milk (if quantity > 0, they took it)
                final customerTook = qty > 0;

                if (milkEntries.containsKey(day)) {
                  // AGGREGATE SAME DAY entries
                  milkEntries[day]!['quantity'] += qty;
                  milkEntries[day]!['totalAmount'] += totalAmt;
                  // Update customerTook to true if any entry shows customer took milk
                  milkEntries[day]!['customerTook'] = 
                    (milkEntries[day]!['customerTook'] as bool) || customerTook;
                } else {
                  milkEntries[day] = {
                    'quantity': qty,
                    'fatContent': _toDouble(entry['fatContent']),
                    'pricePerLiter': _toDouble(entry['pricePerLiter']),
                    'totalAmount': totalAmt,
                    'shift': entry['shift'] ?? 'full-day',
                    'verified': entry['verified'] ?? false,
                    'customerTook': customerTook,
                    'date': date,
                  };
                }
              } catch (e) {
                debugPrint('Error parsing entry: $e');
                continue;
              }
            }
          }
        }
      });
    } catch (e) {
      _showSnack('Error loading data: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ─── Entry dialog ─────────────────────────────────────────────────
  void _showEntryDialog(int day) {
    final entry = milkEntries[day];
    final qtyCtrl = TextEditingController(
        text: entry != null ? _toDouble(entry['quantity']).toStringAsFixed(2) : '0');
    final fatCtrl = TextEditingController(
        text: entry != null ? _toDouble(entry['fatContent']).toStringAsFixed(2) : '0');
    final priceCtrl = TextEditingController(
        text: entry != null ? _toDouble(entry['pricePerLiter']).toStringAsFixed(2) : '75');
    String selectedShift = entry?['shift'] ?? 'full-day';
    bool customerTook = entry?['customerTook'] ?? false;

    final now = DateTime.now();
    final monthName = DateFormat.MMMM().format(now);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.water_drop,
                    color: Colors.green, size: 24),
              ),
              const SizedBox(width: 10),
              Text(
                '$day $monthName',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                _buildField(
                  controller: qtyCtrl,
                  label: 'Quantity (Liters)',
                  icon: Icons.water_drop_outlined,
                  iconColor: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: fatCtrl,
                  label: 'Fat Content (%)',
                  icon: Icons.science_outlined,
                  iconColor: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: priceCtrl,
                  label: 'Price per Liter (₹)',
                  icon: Icons.currency_rupee_rounded,
                  iconColor: Colors.green,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedShift,
                  decoration: InputDecoration(
                    labelText: 'Shift',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.schedule_rounded,
                        color: Colors.purple),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'morning', child: Text('🌅  Morning')),
                    DropdownMenuItem(
                        value: 'evening', child: Text('🌆  Evening')),
                    DropdownMenuItem(
                        value: 'full-day', child: Text('☀️  Full Day')),
                  ],
                  onChanged: (v) =>
                      setDS(() => selectedShift = v!),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Customer Collected Milk'),
                  subtitle: const Text('Toggle if milk was picked up'),
                  value: customerTook,
                  activeColor: _customerTookColor,
                  secondary: Icon(
                    customerTook
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color:
                        customerTook ? _customerTookColor : Colors.grey,
                  ),
                  onChanged: (v) => setDS(() => customerTook = v),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () async {
                final qty =
                    double.tryParse(qtyCtrl.text) ?? 0;
                final fat =
                    double.tryParse(fatCtrl.text) ?? 0;
                final price =
                    double.tryParse(priceCtrl.text) ?? 75;
                final total = qty * price;

                setState(() {
                  milkEntries[day] = {
                    'quantity': qty,
                    'fatContent': fat,
                    'pricePerLiter': price,
                    'totalAmount': total,
                    'shift': selectedShift,
                    'verified': false,
                    'customerTook': customerTook,
                  };
                });

                await _saveToBackend(
                    day, qty, fat, price, total,
                    selectedShift, customerTook);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: iconColor),
      ),
    );
  }

  // ─── Save to backend ──────────────────────────────────────────────
  Future<void> _saveToBackend(
    int day,
    double qty,
    double fat,
    double price,
    double total,
    String shift,
    bool customerTook,
  ) async {
    try {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, day);

      final response = await http.post(
        Uri.parse('$_backendUrl/milk-entry/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': widget.phoneNumber,
          'date': date.toIso8601String(),
          'quantity': qty,
          'fatContent': fat,
          'pricePerLiter': price,
          'totalAmount': total,
          'shift': shift,
          'customerTook': customerTook,
          'year': now.year,
          'month': now.month,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack('✅ Entry saved!', Colors.green);
        await _fetchMonthData();
      } else {
        throw Exception('Server responded ${response.statusCode}');
      }
    } catch (e) {
      _showSnack('Error saving: $e', Colors.red);
    }
  }

  // ─── Razorpay payment ─────────────────────────────────────────────
  void _payViaRazorpay() {
    if (totalBill <= 0) {
      _showSnack('No pending bill to pay.', Colors.orange);
      return;
    }

    final keyId = dotenv.env['RAZORPAY_KEY_ID'] ?? '';
    if (keyId.isEmpty) {
      _showSnack('Razorpay key not configured in .env', Colors.red);
      return;
    }

    final options = {
      'key': keyId,
      'amount': (totalBill * 100).toInt(), // paise
      'name': 'Sobhnath Dairy Farm',
      'description': 'Milk Bill – ${widget.phoneNumber}',
      'prefill': {
        'contact': widget.phoneNumber,
        'name': widget.customerName,
      },
      'theme': {'color': '#1B5E20'},
      'send_sms_hash': true,
      'retry': {'enabled': true, 'max_count': 2},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _showSnack('Could not open payment: $e', Colors.red);
    }
  }

  // ─── Refresh bill locally ─────────────────────────────────────────
  void _refreshBill() {
    setState(() {
      totalBill = currentMonthAmount;
    });
    _showSnack('Bill amount refreshed from server', Colors.green);
  }

  // ─── Logout ───────────────────────────────────────────────────────
  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ─── Calendar tile color logic ────────────────────────────────────
  Color _tileColor(int day) {
    final now = DateTime.now();
    final entry = milkEntries[day];
    
    // Highlight today
    if (day == now.day) return _todayColor;
    
    // No entry
    if (entry == null) return _emptyColor;
    
    // Check if there's milk quantity
    final qty = _toDouble(entry['quantity']);
    if (qty <= 0) return _emptyColor;
    
    // Entry exists - color based on whether customer took milk
    final took = entry['customerTook'] as bool? ?? false;
    return took ? _customerTookColor : _entryColor;
  }

  Color _tileForeground(int day) {
    final c = _tileColor(day);
    return (c == _emptyColor || c == _todayColor) ? Colors.black87 : Colors.white;
  }

  // Helper to check if a date has an entry
  String _getEntrySummary(int day) {
    final entry = milkEntries[day];
    if (entry == null) return '';
    final qty = _toDouble(entry['quantity']);
    if (qty <= 0) return '';
    return '${qty.toStringAsFixed(1)}L';
  }

  // ─── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text(
          widget.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _fetchMonthData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      // ── Drawer ───────────────────────────────────────────────────
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.water_drop,
                          size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sobhnath Dairy',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.phoneNumber,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            _drawerTile(
              icon: Icons.person_rounded,
              label: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                        phoneNumber: widget.phoneNumber),
                  ),
                );
              },
            ),
            _drawerTile(
              icon: Icons.pets_rounded,
              label: 'Gaushala',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GaushalaScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            _drawerTile(
              icon: Icons.logout_rounded,
              label: 'Logout',
              iconColor: Colors.red,
              onTap: _logout,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

      // ── Body ──────────────────────────────────────────────────────
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
          : Column(
              children: [
                // Month header
                _buildMonthHeader(now),

                // Legend
                _buildLegend(),

                // Calendar grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (ctx, i) {
                      final day = i + 1;
                      final entry = milkEntries[day];
                      final qty = entry != null ? _toDouble(entry['quantity']) : 0.0;
                      final hasEntry = qty > 0;
                      final fg = _tileForeground(day);
                      final bg = _tileColor(day);
                      final isToday = day == now.day;

                      return GestureDetector(
                        onTap: () => _showEntryDialog(day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius:
                                BorderRadius.circular(10),
                            border: isToday
                                ? Border.all(
                                    color: Colors.white,
                                    width: 2)
                                : null,
                            boxShadow: hasEntry
                                ? [
                                    BoxShadow(
                                      color: bg.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset:
                                          const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                '$day',
                                style: TextStyle(
                                  color: fg,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              if (hasEntry) ...[
                                const SizedBox(height: 1),
                                Icon(
                                  Icons.water_drop,
                                  size: 11,
                                  color:
                                      fg.withOpacity(0.9),
                                ),
                                Text(
                                  _getEntrySummary(day),
                                  style: TextStyle(
                                    color: fg,
                                    fontSize: 9,
                                    fontWeight:
                                        FontWeight.w600,
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

                // Bill summary bar with amount from API
                _buildBillBar(),
              ],
            ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────

  Widget _buildMonthHeader(DateTime now) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1B5E20),
      ),
      child: Column(
        children: [
          Text(
            DateFormat.yMMMM().format(now),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${milkEntries.length} days with entries',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      color: Colors.white,
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendDot(_customerTookColor, 'Milk Taken'),
          _legendDot(_entryColor, 'Entry Only'),
          _legendDot(_todayColor, 'Today'),
          _legendDot(_emptyColor, 'No Entry', border: true),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label,
      {bool border = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border
                ? Border.all(color: Colors.grey.shade400)
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  Widget _buildBillBar() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Total Bill',
                        style: TextStyle(
                            fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Current Month',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${totalBill.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: _refreshBill,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1B5E20),
              side: const BorderSide(color: Color(0xFF1B5E20)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF1B5E20),
    String? badge,
  }) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          if (badge != null)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
      title: Text(label,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}