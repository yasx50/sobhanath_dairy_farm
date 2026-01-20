import 'package:flutter/material.dart';

class MonthlyReportsScreen extends StatefulWidget {
  final String dairyName;

  const MonthlyReportsScreen({Key? key, required this.dairyName}) : super(key: key);

  @override
  State<MonthlyReportsScreen> createState() => _MonthlyReportsScreenState();
}

class _MonthlyReportsScreenState extends State<MonthlyReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedMonth = 'December 2025';

  // Sample data - replace with actual API data
  final List<Map<String, dynamic>> allReports = [
    {
      'name': 'John Doe',
      'address': 'room no. 101, wing A, building name, area',
      'cowCount': 25,
      'cowRate': 50,
      'cowTotal': 1250,
      'buffaloCount': 15,
      'buffaloRate': 60,
      'buffaloTotal': 900,
      'dues': 0,
      'balance': 0,
      'total': 2150,
      'message': 'Payment completed',
    },
    {
      'name': 'Jane Smith',
      'address': 'room no. 202, wing B, building name, area',
      'cowCount': 30,
      'cowRate': 50,
      'cowTotal': 1500,
      'buffaloCount': 20,
      'buffaloRate': 60,
      'buffaloTotal': 1200,
      'dues': 500,
      'balance': 0,
      'total': 2700,
      'message': 'Dues pending',
    },
  ];

  List<Map<String, dynamic>> filteredReports = [];

  @override
  void initState() {
    super.initState();
    filteredReports = allReports;
    _searchController.addListener(_filterReports);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterReports() {
    setState(() {
      if (_searchController.text.isEmpty) {
        filteredReports = allReports;
      } else {
        filteredReports = allReports.where((report) {
          return report['name']!
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
        }).toList();
      }
    });
  }

  void _selectMonthYear() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Month & Year'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('December 2025'),
              onTap: () {
                setState(() => selectedMonth = 'December 2025');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('November 2025'),
              onTap: () {
                setState(() => selectedMonth = 'November 2025');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _downloadPdf(Map<String, dynamic> report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading PDF for ${report['name']}')),
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
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Monthly Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'search',
                filled: true,
                fillColor: Colors.grey.shade300,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: InkWell(
              onTap: _selectMonthYear,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check),
                    const SizedBox(width: 12),
                    Text(
                      selectedMonth,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredReports.isEmpty
                ? const Center(child: Text('No reports found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _buildReportCard(report);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final messageController = TextEditingController(text: report['message']);

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
                report['name']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(
              'address: ${report['address']}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'cow:${report['cowCount']} rate:${report['cowRate']}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  'xXx=${report['cowTotal']}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'buffalo:${report['buffaloCount']} rate:${report['buffaloRate']}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  'xXx=${report['buffaloTotal']}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'dues:${report['dues'].toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  'balance:${report['balance'].toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'total:${report['total']}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: messageController,
            decoration: InputDecoration(
              hintText: 'message:',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => _downloadPdf(report),
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.download, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}