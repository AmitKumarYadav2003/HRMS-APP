import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/announcement_model.dart';
import '../config/api_config.dart';

class AnnouncementPage {
  final List<Announcement> items;
  final int currentPage;
  final bool hasMore;

  const AnnouncementPage({
    required this.items,
    required this.currentPage,
    required this.hasMore,
  });
}

class AnnouncementService {
static const String _baseUrl = ApiConfig.baseUrl;
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? prefs.getString('token');
  }

  Future<AnnouncementPage> fetchAnnouncements({int page = 1, int perPage = 10}) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User token not found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/announcements?page=$page&per_page=$perPage'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load announcements (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    final pagination = data['pagination'] as Map<String, dynamic>;

    return AnnouncementPage(
      items: list
          .map((item) => Announcement.fromJson(item as Map<String, dynamic>))
          .toList(),
      currentPage: pagination['current_page'] as int,
      hasMore: pagination['has_more'] as bool,
    );
  }
}