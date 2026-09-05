import 'package:flutter/material.dart';
import '../main.dart';
import 'apply_leave_screen.dart';
import 'attendance_screen.dart';
import 'leave_screen.dart';
import 'payslip_screen.dart';
import 'holiday_calendar_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  final List<Map<String, dynamic>> _items = [
    {
      'title': 'Apply Leave',
      'icon': Icons.edit_calendar_rounded,
      'color': AppColors.primary,
      'screen': const ApplyLeaveScreen(),
    },
    {
      'title': 'Attendance',
      'icon': Icons.schedule_rounded,
      'color': const Color(0xFF10B981),
      'screen': const AttendanceScreen(),
    },
    {
      'title': 'Leave History',
      'icon': Icons.beach_access_rounded,
      'color': const Color(0xFFF59E0B),
      'screen': const LeaveScreen(),
    },
    {
      'title': 'Payslips',
      'icon': Icons.receipt_long_rounded,
      'color': const Color(0xFF8B5CF6),
      'screen': const PayslipScreen(),
    },
    {
      'title': 'Holiday Calendar',
      'icon': Icons.calendar_month_rounded,
      'color': const Color(0xFF3B82F6),
      'screen': const HolidayCalendarScreen(),
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return [];
    return _items
        .where(
          (i) => (i['title'] as String).toLowerCase().contains(
            _query.toLowerCase(),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            _buildSearchBar(context),
            const SizedBox(height: 10),
            Expanded(
              child: _query.isEmpty
                  ? const Center(
                      child: Text(
                        'Search leave, attendance, payslip...',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    )
                  : _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final item = _filtered[index];
                        return _resultTile(context, item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primaryDark,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.muted,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultTile(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item['screen'] as Widget),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              item['title'] as String,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
