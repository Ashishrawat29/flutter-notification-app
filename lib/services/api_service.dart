import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:3000"; // backend URL

  // Add event to backend
  static Future<void> addEvent(Map<String, dynamic> event) async {
    final url = Uri.parse("$baseUrl/events");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(event),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Failed to save event: ${response.body}");
    }
  }

  // Fetch events from backend
  static Future<List<dynamic>> getEvents() async {
    final url = Uri.parse("$baseUrl/events");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("Failed to fetch events: ${response.body}");
    }
  }
}
