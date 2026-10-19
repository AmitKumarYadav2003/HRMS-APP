import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../screens/apply_leave_screen.dart';
import '../screens/holiday_calendar_screen.dart';
import '../screens/payslip_screen.dart';
import '../screens/reports_screen.dart';
import '../utils/page_transitions.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuickActionsRow extends StatefulWidget {
  final Map<String, dynamic> leaveBalance;
  final Future<void> Function()? onLeaveApplied;

  const QuickActionsRow({
    super.key,
    required this.leaveBalance,
    this.onLeaveApplied,
  });

  @override
  State<QuickActionsRow> createState() => _QuickActionsRowState();
}

class _QuickActionsRowState extends State<QuickActionsRow> {
  @override

  Future<Map<String, dynamic>?> _fetchLeaveBalance() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) return null;

  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.22:8000/api/leave/balance'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      return {
        'Earned': (data['earned']?['remaining'] as num?)?.toInt() ?? 0,
        'Sick': (data['sick']?['remaining'] as num?)?.toInt() ?? 0,
        'Casual': (data['casual']?['remaining'] as num?)?.toInt() ?? 0,
      };
    }
  } catch (e) {
    debugPrint('Leave balance error: $e');
  }

  return null;
}
  Widget build(BuildContext context) {
    final allActions = [
      _buildAction(context, Icons.edit_calendar_rounded, 'Apply Leave', () async {
  final balance = await _fetchLeaveBalance();

  if (!mounted) return;

  if (balance == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to fetch leave balance')),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ApplyLeaveScreen(
        leaveBalance: balance,
        onBack: null,
      ),
    ),
  );
}),
      _buildAction(context, Icons.description_rounded, 'Payslips', () {
        Navigator.push(context, slideRoute(const PayslipScreen()));
      }),
      _buildAction(context, Icons.calendar_month_rounded, 'Holidays', () {
        Navigator.push(context, slideRoute(const HolidayCalendarScreen()));
      }),
      _buildAction(context, Icons.folder_outlined, 'Documents', () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
      }),
      _buildAction(context, Icons.bar_chart_rounded, 'Reports', () {
        Navigator.push(context, slideRoute(const ReportsScreen()));
      }),
      _buildAction(context, Icons.trending_up_rounded, 'Appraisals', () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
      }),
      _buildAction(context, Icons.support_agent_rounded, 'Service\nRequest', () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
      }),
      _buildAction(context, Icons.cake_rounded, 'Celebrations', () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
      }),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick actions', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 0.8,
            children: allActions,
          ),
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context, IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.10), blurRadius: 10, offset: const Offset(3, 3)),
                BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 10, offset: const Offset(-3, -3)),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 21),
          ),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: const Color(0xFF5B5470), height: 1.3)),
        ],
      ),
    );
  }
}