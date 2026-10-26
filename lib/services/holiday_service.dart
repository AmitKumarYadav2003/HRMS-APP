import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/holiday_model.dart';

class HolidayService {
  Future<List<Holiday>> fetchHolidays() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? prefs.getString('token');
    if (token == null) {
      throw Exception('User token not found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/holidays'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load holidays (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;

    return list
        .map((item) => Holiday.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}