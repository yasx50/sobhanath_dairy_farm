import 'package:intl/intl.dart';
import '../services/firebase_service.dart';

class BillingHelper {
  final FirebaseService _svc = FirebaseService();

  // calculate monthly total quantity and amount given rate per liter
  Future<void> generateMonthlyBill(String customerId, int year, int month, double ratePerLiter) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    final entries = await _svc.getEntriesForCustomerBetween(customerId, start, end);
    double total = 0;
    for (var e in entries) total += e.quantity;
    final amount = total * ratePerLiter;
    final monthKey = DateFormat('yyyy-MM').format(start);
    final bill = {
      'customerId': customerId,
      'month': monthKey,
      'totalQuantity': total,
      'amount': amount,
      'paid': false,
      'generatedAt': DateTime.now(),
    };
    await _svc.createBill(/* construct Bill object or call create with map */);
    // NOTE: adapt to Bill model in your implementation
  }
}
