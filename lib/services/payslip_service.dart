import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/payslip_model.dart';

class PayslipService {
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Login expired. Please log in again.');
    }
    return token;
  }

  Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  void _checkStatus(int statusCode) {
    if (statusCode == 200) return;
    if (statusCode == 401) throw Exception('Login expired. Please log in again.');
    if (statusCode == 404) throw Exception('Payslip not found.');
    throw Exception('Error fetching payslip ($statusCode).');
  }

  Future<List<PayslipSummary>> fetchHistory() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/payslip/history'),
      headers: _headers(token),
    );
    _checkStatus(response.statusCode);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;

    return list
        .map((item) => PayslipSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PayslipDetail> fetchDetail(int id) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/payslip/$id'),
      headers: _headers(token),
    );
    _checkStatus(response.statusCode);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PayslipDetail.fromJson(data['data'] as Map<String, dynamic>);
  }
}