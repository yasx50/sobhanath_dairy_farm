import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  const CustomerCard({super.key, required this.customer, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(customer.name),
        subtitle: Text(customer.phone),
        onTap: onTap,
      ),
    );
  }
}
