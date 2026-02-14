import 'package:flutter/material.dart';

class GauShalaManagementScreen extends StatelessWidget {
  final String dairyName;

  const GauShalaManagementScreen({
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
          '$dairyName – Gau Shala',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
          _sectionTitle('Our Cows 🐄'),
          _cowCard('Ganga', 'Healthy desi cow'),
          _cowCard('Yamuna', 'Milk producing cow'),
          _cowCard('Nandi', 'Rescued cow'),

          const SizedBox(height: 24),

          _sectionTitle('Photos & Videos 📸🎥'),
          _actionCard(
            icon: Icons.add_photo_alternate_outlined,
            title: 'Add Photos',
            subtitle: 'Upload cow photos',
          ),
          _actionCard(
            icon: Icons.video_call_outlined,
            title: 'Add Videos',
            subtitle: 'Upload cow videos',
          ),

          const SizedBox(height: 24),

          _sectionTitle('Gau Mata Quotes 🕉️'),
          _quoteCard('“Gau seva is the highest form of seva.”'),
          _quoteCard('“Serving cows brings peace and prosperity.”'),

          const SizedBox(height: 24),

          _sectionTitle('Support Gau Seva ❤️'),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Donation feature coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Donate for Gau Seva',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- WIDGETS ----------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _cowCard(String name, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _quoteCard(String quote) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        quote,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 14,
        ),
      ),
    );
  }
}
