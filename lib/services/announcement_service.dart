import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  static const String _baseUrl = 'http://192.168.1.22:8000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? prefs.getString('token');
  }

  Future<List<Announcement>> fetchAnnouncements({int limit = 10}) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User token not found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/announcements?limit=$limit'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load announcements (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    final list = data['data'] as List<dynamic>;

    return list
        .map((item) => Announcement.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}