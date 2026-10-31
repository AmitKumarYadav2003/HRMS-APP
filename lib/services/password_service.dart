import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class PasswordService {
  Future<void> changePassword(String current, String newPass, String confirm) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/change-password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': current,
        'new_password': newPass,
        'new_password_confirmation': confirm,
      }),
    );

    if (res.statusCode == 200) return;

    final body = jsonDecode(res.body);
    throw Exception(body['message'] ?? 'Cannot change password.');
  }
}