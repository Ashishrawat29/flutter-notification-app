import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000";
  // ⚠️ use 10.0.2.2 for Android Emulator, or http://localhost:5000 for web

  /// Upload music file
  static Future<Map<String, dynamic>> uploadMusic(File file) async {
    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/music/upload"));
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      return jsonDecode(resStr);
    } else {
      throw Exception("Failed to upload music");
    }
  }

  /// Get all music files
  static Future<List<dynamic>> getMusic() async {
    final response = await http.get(Uri.parse("$baseUrl/music"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch music");
    }
  }

  /// Create new event
  static Future<Map<String, dynamic>> createEvent(
      String title, DateTime date, String musicId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/events"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "date": date.toIso8601String(),
        "musicId": musicId,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create event");
    }
  }

  /// Get all events
  static Future<List<dynamic>> getEvents() async {
    final response = await http.get(Uri.parse("$baseUrl/events"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch events");
    }
  }
}
