import 'package:flutter/material.dart';

class MilkEntriesScreen extends StatefulWidget {
  final String dairyName;

  const MilkEntriesScreen({Key? key, required this.dairyName}) : super(key: key);

  @override
  State<MilkEntriesScreen> createState() => _MilkEntriesScreenState();
}

class _MilkEntriesScreenState extends State<MilkEntriesScreen> {
  // Sample data - replace with actual API data
  final List<Map<String, dynamic>> milkEntries = [
    {
      'name': 'John Doe',
      'cow': 5,
      'buffalo': 3,
      'message': '',
      'date': '24 Dec 2025, 10:30 AM',
    },
    {
      'name': 'Jane Smith',
      'cow': 0,
      'buffalo': 2,
      'message': '',
      'date': '24 Dec 2025, 09:15 AM',
    },
    {
      'name': 'Mike Johnson',
      'cow': 8,
      'buffalo': 0,
      'message': '',
      'date': '24 Dec 2025, 08:45 AM',
    },
  ];

  void _acceptEntry(int index) {
    setState(() {
      milkEntries.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry accepted'), backgroundColor: Colors.green),
    );
  }

  void _rejectEntry(int index) {
    setState(() {
      milkEntries.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry rejected'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.dairyName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Milk Entries',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'date&time',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: milkEntries.isEmpty
                ? const Center(child: Text('No milk entries'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: milkEntries.length,
                    itemBuilder: (context, index) {
                      final entry = milkEntries[index];
                      return _buildEntryCard(entry, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry, int index) {
    final messageController = TextEditingController(text: entry['message']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Text(
                entry['name']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.pets, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'cow:${entry['cow'].toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'buffalo:${entry['buffalo'].toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: messageController,
            decoration: InputDecoration(
              hintText: 'correction message:',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            maxLines: 2,
            onChanged: (value) {
              entry['message'] = value;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptEntry(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('accept', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _rejectEntry(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('reject', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}