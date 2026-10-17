import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'apply_leave_screen.dart';
import 'dashboard_screen.dart';
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

  final List<Map<String, dynamic>> _history = [];
  int _earnedBalance = 12;
  int _sickBalance = 5;
  int _casualBalance = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchLeaveHistory();
    _fetchLeaveBalance();
  }

  Future<void> _fetchLeaveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.22:8000/api/leave/history'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          _history.clear();

          for (final leave in data['data']) {
            final fromDate = DateTime.parse(leave['from_date']);
            final toDate = DateTime.parse(leave['to_date']);
            final days = toDate.difference(fromDate).inDays + 1;

            final rawStatus = (leave['status'] ?? 'pending').toString();

            _history.add({
              'type': leave['leave_type'] ?? 'Leave',
              'date': '${leave['from_date']} - ${leave['to_date']}',
              'days': '$days Day${days > 1 ? 's' : ''}',
              'status': rawStatus[0].toUpperCase() + rawStatus.substring(1),
              'admin_remarks': leave['admin_remarks'],
              'reason': leave['reason'],
            });
          }
        });
      } else {
        debugPrint('Leave history failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching leave history: $e');
    }
  }

  Future<void> _fetchLeaveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.22:8000/api/leave/balance'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final data = result['data'];

        if (!mounted) return;

        setState(() {
          _earnedBalance =
              (data['earned']?['remaining'] as num?)?.toInt() ?? 12;
          _sickBalance = (data['sick']?['remaining'] as num?)?.toInt() ?? 5;
          _casualBalance = (data['casual']?['remaining'] as num?)?.toInt() ?? 10;
        });
      } else {
        debugPrint('Leave balance failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching leave balance: $e');
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
            Expanded(child: _buildMyLeaves()),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApplyLeaveScreen(
  leaveBalance: {
    'Earned': _earnedBalance,
    'Sick': _sickBalance,
    'Casual': _casualBalance,
  },
  onBack: () async {
    await _fetchLeaveHistory();
    if (mounted) Navigator.pop(context);
  },
),
                ),
              );
            },
            child: const Center(
              child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                (route) => false,
              );
            },
            child: Container(
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
          ),
          const SizedBox(width: 4),
          Text(
            'Leave',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
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
              _miniBalance(
                '$_earnedBalance',
                'Earned',
                Icons.calendar_today_rounded,
              ),
              const SizedBox(width: 10),
              _miniBalance(
                _sickBalance.toString().padLeft(2, '0'),
                'Sick',
                Icons.shield_outlined,
              ),
              const SizedBox(width: 10),
              _miniBalance(
                _casualBalance.toString().padLeft(2, '0'),
                'Casual',
                Icons.coffee_outlined,
              ),
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

          ...(_upcomingLeaves.isEmpty
              ? [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'No upcoming approved leaves',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ]
              : _upcomingLeaves.map((leave) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
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
                                  '${leave['type']} Leave',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  leave['date'],
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _badge('Approved', const Color(0xFF16A34A)),
                        ],
                      ),
                    ),
                  );
                }).toList()),

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

                              if ((h['admin_remarks'] ?? '')
                                  .toString()
                                  .trim()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Admin remarks: ${h['admin_remarks']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
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

  List<Map<String, dynamic>> get _upcomingLeaves {
    final today = DateTime.now();

    return _history.where((leave) {
      final dates = (leave['date'] as String).split(' - ');
      final toDate = DateTime.tryParse(dates.last);

      return toDate != null &&
          !toDate.isBefore(DateTime(today.year, today.month, today.day)) &&
          leave['status'] == 'Approved';
    }).toList();
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
      {
        'type': 'Earned Leave',
        'total': 12,
        'used': 12 - _earnedBalance,
        'left': _earnedBalance,
      },
      {
        'type': 'Sick Leave',
        'total': 5,
        'used': 5 - _sickBalance,
        'left': _sickBalance,
      },
      {
        'type': 'Casual Leave',
        'total': 10,
        'used': 10 - _casualBalance,
        'left': _casualBalance,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        children: data.map((d) {
          final total = d['total'] as int;
          final used = d['used'] as int;
          final left = d['left'] as int;
          final progress = total > 0 ? used / total : 0.0;

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
                      '$left left',
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
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$used used of $total total',
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
