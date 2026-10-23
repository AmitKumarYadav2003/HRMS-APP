import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'slide_to_punch.dart';
import '../config/api_config.dart';

class PunchSection extends StatefulWidget {
  // const PunchSection({super.key});
  final VoidCallback? onPunchSuccess;

  const PunchSection({
  super.key,
  this.onPunchSuccess,
});

  @override
  State<PunchSection> createState() => _PunchSectionState();
}

class _PunchSectionState extends State<PunchSection> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _checkInTime;
  String? _checkOutTime;

  bool get _hasCheckedIn => _checkInTime != null && _checkInTime!.isNotEmpty;
  bool get _hasCheckedOut => _checkOutTime != null && _checkOutTime!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _fetchTodayAttendance();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? prefs.getString('token');
  }

  Future<void> _fetchTodayAttendance() async {
    final token = await _getToken();
    if (token == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/attendance/today'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final attendance = data['data'];

        setState(() {
          if (attendance != null) {
            _checkInTime = attendance['check_in']?.toString();
            _checkOutTime = attendance['check_out']?.toString();
          } else {
            _checkInTime = null;
            _checkOutTime = null;
          }
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePunch() async {
    if (_isSubmitting || _hasCheckedOut) return;

    final token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User token not found. Please log in again.')),
        );

      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final endpoint = !_hasCheckedIn ? 'check-in' : 'check-out';
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/attendance/$endpoint'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final resData = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        final attendance = resData['data'];
        setState(() {
          if (attendance != null) {
            _checkInTime = attendance['check_in']?.toString() ?? _checkInTime;
            _checkOutTime = attendance['check_out']?.toString() ?? _checkOutTime;
          }
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resData['message'] ?? 'Attendance marked successfully'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        widget.onPunchSuccess?.call(); // Notify parent widget of successful punch
        await _fetchTodayAttendance(); // Refresh the attendance data after marking
      } else if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resData['message'] ?? 'Failed to update attendance'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.orangeLight,
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.all(4),
        child: _isLoading
            ? const SizedBox(
                height: 56,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : SlideToPunch(
                punched: _hasCheckedIn,
                isCompleted: _hasCheckedOut,
                label: _isSubmitting
                    ? 'Updating...'
                    : (_hasCheckedOut
                        ? 'Completed for Today'
                        : (!_hasCheckedIn
                            ? 'Slide to Punch In'
                            : 'Slide to Punch Out')),
                onComplete: _handlePunch,
                isDark: false,
              ),
      ),
    );
  }
}