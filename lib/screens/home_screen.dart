import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';
import 'customer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cp = Provider.of<CustomerProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shobhnath Dairy'),
        actions: [
          IconButton(onPressed: () => auth.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: cp.isLoading ? const Center(child: CircularProgressIndicator()) :
      ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ElevatedButton.icon(
            onPressed: () => _openAddCustomer(context, cp),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Customer'),
          ),
          const SizedBox(height: 12),
          ...cp.customers.map((c) => Card(
            child: ListTile(
              title: Text(c.name),
              subtitle: Text('${c.phone}\n${c.address}'),
              isThreeLine: true,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerScreen(customer: c))),
            ),
          )).toList(),
        ],
      ),
    );
  }

  void _openAddCustomer(BuildContext ctx, cp) {
    showDialog(context: ctx, builder: (_) {
      return AlertDialog(
        title: const Text('New Customer'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async {
            if (_name.text.trim().isEmpty) return;
            final c = Customer(id: '', name: _name.text.trim(), phone: _phone.text.trim(), address: _address.text.trim());
            await cp.addCustomer(c);
            _name.clear(); _phone.clear(); _address.clear();
            Navigator.pop(ctx);
          }, child: const Text('Add'))
        ],
      );
    });
  }
}
