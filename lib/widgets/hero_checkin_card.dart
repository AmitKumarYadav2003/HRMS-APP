import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'slide_to_punch.dart';

class HeroCheckinCard extends StatefulWidget {
  const HeroCheckinCard({super.key});

  @override
  State<HeroCheckinCard> createState() => _HeroCheckinCardState();
}

class _HeroCheckinCardState extends State<HeroCheckinCard> {
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

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '--:--';
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final h12 = hour % 12 == 0 ? 12 : hour % 12;
        return '${h12.toString().padLeft(2, '0')}:$minute $period';
      }
    } catch (_) {}
    return timeStr;
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
        Uri.parse('http://192.168.1.22:8000/api/attendance/today'),
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
        Uri.parse('http://192.168.1.22:8000/api/attendance/$endpoint'),
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
    final todayFormatted = DateFormat('EEE, dd MMM').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Attendance",
                style: GoogleFonts.poppins(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                todayFormatted,
                style: GoogleFonts.inter(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryLight2, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Punch In',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isLoading
                          ? '...'
                          : (_hasCheckedIn ? _formatTime(_checkInTime) : '--:--'),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Punch Out',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_hasCheckedOut)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF6EE7B7),
                            size: 15,
                          ),
                        if (_hasCheckedOut) const SizedBox(width: 4),
                        Text(
                          _isLoading
                              ? '...'
                              : (_hasCheckedOut
                                  ? _formatTime(_checkOutTime)
                                  : 'Pending'),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: _hasCheckedOut ? 20 : 16,
                            fontWeight: _hasCheckedOut
                                ? FontWeight.w800
                                : FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.accent,
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
        ],
      ),
    );
  }
}