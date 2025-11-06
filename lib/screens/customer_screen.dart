import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'billing_screen.dart';
import '../models/customer.dart';

class CustomerScreen extends StatelessWidget {
  final Customer customer;
  const CustomerScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(title: const Text('Phone'), subtitle: Text(customer.phone)),
            ListTile(title: const Text('Address'), subtitle: Text(customer.address)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text('Open Calendar'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarScreen(customerId: customer.id)));
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.receipt_long),
              label: const Text('Billing'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => BillingScreen(customerId: customer.id)));
              },
            ),
            const SizedBox(height: 12),
            const Text('History and entries are visible in calendar and billing screens.'),
          ],
        ),
      ),
    );
  }
}
