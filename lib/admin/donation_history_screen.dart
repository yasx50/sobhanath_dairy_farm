import 'package:flutter/material.dart';

class DonationHistoryScreen extends StatelessWidget {
  final String dairyName;

  const DonationHistoryScreen({
    Key? key,
    required this.dairyName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '$dairyName – Donations',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _donationCard(
            name: 'Ramesh Patel',
            amount: '₹500',
            date: '10 Sept 2025',
          ),
          _donationCard(
            name: 'Sita Sharma',
            amount: '₹1,000',
            date: '08 Sept 2025',
          ),
          _donationCard(
            name: 'Anonymous',
            amount: '₹250',
            date: '05 Sept 2025',
          ),
        ],
      ),
    );
  }

  // ---------------- WIDGET ----------------

  Widget _donationCard({
    required String name,
    required String amount,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.volunteer_activism, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
