import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for iOS/Web
  static const String baseUrl = 'http://10.0.2.2:8000'; 

  Future<Map<String, dynamic>?> createDairy(String ownerId, String name, String address) async {
    final url = Uri.parse('$baseUrl/dairy/create');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'owner_id': ownerId,
          'name': name,
          'address': address,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to create dairy: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating dairy: $e');
      return null;
    }
  }

  Future<List<dynamic>> getDairyByOwner(String ownerId) async {
    final url = Uri.parse('$baseUrl/dairy/$ownerId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to get dairy: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting dairy: $e');
      return [];
    }
  }
}
