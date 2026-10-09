import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'apply_leave_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _history = [
    {
      'type': 'Sick Leave',
      'date': 'Tue, 10 Jun 2026',
      'days': '1 Day',
      'status': 'Approved',
    },
    {
      'type': 'Casual Leave',
      'date': 'Fri, 16 May 2026',
      'days': '1 Day',
      'status': 'Approved',
    },
    {
      'type': 'Annual Leave',
      'date': 'Mon, 07 Apr - Fri, 11 Apr 2026',
      'days': '5 Days',
      'status': 'Approved',
    },
    {
      'type': 'Annual Leave',
      'date': 'Mon, 16 Dec - Tue, 17 Dec 2025',
      'days': '2 Days',
      'status': 'Rejected',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchLeaveHistory();
  }

  Future<void> _fetchLeaveHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) return;

  final response = await http.get(
    Uri.parse('http://192.168.1.22:8000/api/leave/history'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    setState(() {
  _history.clear();

  for (final leave in data['data']) {
    final fromDate = DateTime.parse(leave['from_date']);
    final toDate = DateTime.parse(leave['to_date']);

    final days = toDate.difference(fromDate).inDays + 1;

    _history.add({
      'type': leave['leave_type'],
      'date': '${leave['from_date']} - ${leave['to_date']}',
      'days': '$days Day${days > 1 ? 's' : ''}',
      'status': leave['status'],
    });
  }
});
  }
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    if (status == 'Approved') return const Color(0xFF10B981);
    if (status == 'Rejected') return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyLeaves(),

                   ApplyLeaveScreen(
        onBack: () async {
          await _fetchLeaveHistory();
          _tabController.animateTo(0);
        },
      ),

                  _buildLeaveBalance(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Leave',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          GestureDetector(
            onTap: () => _tabController.animateTo(1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Apply Leave',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
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

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.primary,
      indicatorWeight: 2.5,
      labelStyle: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      tabs: const [
        Tab(text: 'My Leaves'),
        Tab(text: 'Apply Leave', icon: Icon(Icons.add)),
        Tab(text: 'Leave Balance'),
      ],
    );
  }

  Widget _buildMyLeaves() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _miniBalance('12', 'Annual', Icons.calendar_today_rounded),
              const SizedBox(width: 10),
              _miniBalance('05', 'Sick', Icons.shield_outlined),
              const SizedBox(width: 10),
              _miniBalance('02', 'Casual', Icons.coffee_outlined),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Upcoming Leave',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Annual Leave',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'Mon, 25 Aug - Fri, 29 Aug 2026',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                _badge('Pending', const Color(0xFFF59E0B)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent History',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 14),
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: List.generate(_history.length, (i) {
        final h = _history[i];
        final color = _statusColor(h['status']);
        final isLast = i == _history.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: AppColors.border),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h['type'],
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${h["date"]} · ${h["days"]}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _badge(h['status'], color),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _miniBalance(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.primary.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLeaveBalance() {
    final data = [
      {'type': 'Annual Leave', 'total': 18, 'used': 6, 'left': 12},
      {'type': 'Sick Leave', 'total': 8, 'used': 3, 'left': 5},
      {'type': 'Casual Leave', 'total': 6, 'used': 4, 'left': 2},
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        children: data.map((d) {
          final progress = (d['used'] as int) / (d['total'] as int);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 10,
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
                      d['type'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      '${d["left"]} left',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${d["used"]} used of ${d["total"]} total',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
