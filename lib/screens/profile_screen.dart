import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final String phoneNumber;
  
  const ProfileScreen({super.key, required this.phoneNumber});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  Map<String, dynamic>? customerData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCustomerProfile();
  }

  Future<void> _fetchCustomerProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.100:5000/customer/${widget.phoneNumber}'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          // Extract the customer object from the response
          customerData = jsonResponse['customer'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load profile';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Not provided';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'Not provided';
    }
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(errorMessage!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchCustomerProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchCustomerProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.green,
                                backgroundImage: customerData?['avatar'] != null
                                    ? NetworkImage(customerData!['avatar'])
                                    : null,
                                child: customerData?['avatar'] == null
                                    ? Text(
                                        (customerData?['name'] ?? 'U')[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 40,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                customerData?['name'] ?? 'Customer',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.phoneNumber,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Personal Information
                        _buildSectionTitle('Personal Information'),
                        _buildInfoCard(
                          'Gender',
                          customerData?['gender'] != null 
                            ? customerData!['gender'].toString().toUpperCase()
                            : 'Not specified',
                          Icons.person,
                        ),
                        _buildInfoCard(
                          'Date of Birth',
                          _formatDate(customerData?['dob']),
                          Icons.cake,
                        ),

                        // Address Information
                        if (customerData?['address'] != null) ...[
                          _buildSectionTitle('Address'),
                          if (customerData!['address']['street'] != null)
                            _buildInfoCard(
                              'Street',
                              customerData!['address']['street'],
                              Icons.home,
                            ),
                          if (customerData!['address']['city'] != null)
                            _buildInfoCard(
                              'City',
                              customerData!['address']['city'],
                              Icons.location_city,
                            ),
                          if (customerData!['address']['state'] != null)
                            _buildInfoCard(
                              'State',
                              customerData!['address']['state'],
                              Icons.map,
                            ),
                          if (customerData!['address']['pincode'] != null)
                            _buildInfoCard(
                              'Pincode',
                              customerData!['address']['pincode'],
                              Icons.pin_drop,
                            ),
                          _buildInfoCard(
                            'Country',
                            customerData!['address']['country'] ?? 'India',
                            Icons.flag,
                          ),
                        ],

                        // Milk Settings
                        if (customerData?['milkSettings'] != null) ...[
                          _buildSectionTitle('Milk Preferences'),
                          _buildInfoCard(
                            'Default Price per Liter',
                            '₹${customerData!['milkSettings']['defaultPricePerLiter'] ?? 75}',
                            Icons.currency_rupee,
                          ),
                          _buildInfoCard(
                            'Default Shift',
                            (customerData!['milkSettings']['defaultShift'] ?? 'full-day')
                                .toString()
                                .replaceAll('-', ' ')
                                .toUpperCase(),
                            Icons.access_time,
                          ),
                          _buildInfoCard(
                            'Measurement Unit',
                            (customerData!['milkSettings']['measurementUnit'] ?? 'liter')
                                .toString()
                                .toUpperCase(),
                            Icons.straighten,
                          ),
                        ],

                        // Milk Records Summary
                        if (customerData?['milkRecords'] != null) ...[
                          _buildSectionTitle('Current Month Summary'),
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Total Quantity',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${customerData!['milkRecords']['currentMonthTotal'] ?? 0} L',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'Total Amount',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '₹${customerData!['milkRecords']['currentMonthAmount'] ?? 0}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Current Year: ${customerData!['milkRecords']['currentYear'] ?? DateTime.now().year}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Account Information
                        _buildSectionTitle('Account Information'),
                        _buildInfoCard(
                          'Member Since',
                          _formatDate(customerData?['createdAt']),
                          Icons.calendar_today,
                        ),
                        _buildInfoCard(
                          'Last Updated',
                          _formatDate(customerData?['updatedAt']),
                          Icons.update,
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }
}