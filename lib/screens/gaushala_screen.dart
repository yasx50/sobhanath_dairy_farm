import 'package:flutter/material.dart';

class GaushalaScreen extends StatelessWidget {
  const GaushalaScreen({super.key});

  void _showDonationDialog(BuildContext context) {
    final amountController = TextEditingController();
    String selectedAmount = '500';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.favorite, color: Colors.red),
              SizedBox(width: 8),
              Text('Donate to Gaushala'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your donation helps us take care of our beloved cows',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quick Amount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['100', '500', '1000', '2000'].map((amount) {
                    return ChoiceChip(
                      label: Text('₹$amount'),
                      selected: selectedAmount == amount,
                      onSelected: (selected) {
                        setDialogState(() {
                          selectedAmount = amount;
                          amountController.text = amount;
                        });
                      },
                      selectedColor: Colors.green,
                      labelStyle: TextStyle(
                        color: selectedAmount == amount ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Custom Amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                    hintText: 'Enter amount',
                  ),
                  onChanged: (value) {
                    setDialogState(() => selectedAmount = value);
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
              onPressed: () {
                final amount = int.tryParse(selectedAmount) ?? 0;
                if (amount > 0) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Thank you for your donation of ₹$amount!'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Donate Now'),
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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    breed,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Age: $age',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
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
        title: const Text('Gaushala'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.pets,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sobhnath Gaushala',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Protecting and Caring for Sacred Cows',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We currently care for 25+ cows in our gaushala. Your support helps us provide food, shelter, and medical care.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cows List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildCowCard(
                  name: 'Ganga',
                  breed: 'Gir',
                  age: '5 years',
                  description: 'A gentle soul who loves to graze in the morning sun. Ganga is one of our oldest residents and produces high-quality milk.',
                  icon: Icons.pets,
                  color: Colors.brown,
                ),
                _buildCowCard(
                  name: 'Lakshmi',
                  breed: 'Sahiwal',
                  age: '3 years',
                  description: 'Young and energetic, Lakshmi is very friendly and loves to interact with visitors. She has a beautiful light brown coat.',
                  icon: Icons.favorite,
                  color: Colors.pink,
                ),
                _buildCowCard(
                  name: 'Kamadhenu',
                  breed: 'Red Sindhi',
                  age: '7 years',
                  description: 'Our most senior and wise cow. Kamadhenu is calm and peaceful, often found resting under the shade.',
                  icon: Icons.spa,
                  color: Colors.green,
                ),
                _buildCowCard(
                  name: 'Nandini',
                  breed: 'Jersey Cross',
                  age: '2 years',
                  description: 'The youngest member of our gaushala family. Nandini is playful and brings joy to everyone around.',
                  icon: Icons.child_care,
                  color: Colors.blue,
                ),
                _buildCowCard(
                  name: 'Surabhi',
                  breed: 'Tharparkar',
                  age: '4 years',
                  description: 'A healthy and strong cow with a calm temperament. Surabhi is known for her excellent milk quality.',
                  icon: Icons.star,
                  color: Colors.amber,
                ),
              ],
            ),
          ),

          // Donation Button
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
                const Text(
                  'Support Our Gaushala',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Every contribution helps provide better care for our cows',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDonationDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.volunteer_activism, size: 24),
                    label: const Text(
                      'Donate Now',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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