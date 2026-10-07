import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic> _stats = {
    'total_days': 0,
    'present': 0,
    'absent': 0,
    'late': 0,
    'percentage': 0.0,
  };

  List<Map<String, dynamic>> _week = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
  }

  Future<void> _fetchAttendanceHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication token not found';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.22:8000/api/attendance/history'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final statsData = decoded['stats'] ?? {};
        final listData = (decoded['data'] as List<dynamic>?) ?? [];

        final List<Map<String, dynamic>> parsedWeek = [];

        for (var item in listData) {
          final dateStr = item['date']?.toString() ?? '';
          DateTime? parsedDate;
          try {
            parsedDate = DateTime.parse(dateStr);
          } catch (_) {}

          final label = parsedDate != null ? DateFormat('EEE').format(parsedDate) : 'Day';
          final dateDay = parsedDate != null ? DateFormat('dd').format(parsedDate) : '--';
          final full = parsedDate != null ? DateFormat('EEEE, dd MMM').format(parsedDate) : dateStr;

          String formatTime(dynamic timeStr) {
            if (timeStr == null || timeStr.toString().trim().isEmpty) return '--:--';
            try {
              final parts = timeStr.toString().split(':');
              if (parts.length >= 2) {
                final hour = int.parse(parts[0]);
                final minute = parts[1];
                final period = hour >= 12 ? 'PM' : 'AM';
                final h12 = hour % 12 == 0 ? 12 : hour % 12;
                return '${h12.toString().padLeft(2, '0')}:$minute $period';
              }
            } catch (_) {}
            return timeStr.toString();
          }

          final status = (item['status']?.toString() ?? 'absent').toLowerCase();
          String tag;
          if (status == 'present') {
            tag = 'On Time';
          } else if (status == 'late') {
            tag = 'Late';
          } else {
            tag = 'Absent';
          }

          parsedWeek.add({
            'label': label,
            'date': dateDay,
            'status': status,
            'full': full,
            'checkIn': formatTime(item['check_in']),
            'checkOut': formatTime(item['check_out']),
            'tag': tag,
          });
        }

        setState(() {
          _stats = {
            'total_days': statsData['total_days'] ?? 0,
            'present': statsData['present'] ?? 0,
            'absent': statsData['absent'] ?? 0,
            'late': statsData['late'] ?? 0,
            'percentage': (statsData['percentage'] is num)
                ? (statsData['percentage'] as num).toDouble()
                : 0.0,
          };
          _week = parsedWeek;
          if (_week.isNotEmpty) {
            _selectedIndex = _week.length - 1; // latest date selected by default
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load attendance (status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return const Color(0xFF10B981);
      case 'absent':
        return const Color(0xFFEF4444);
      case 'late':
        return AppColors.orange;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _week.isNotEmpty && _selectedIndex < _week.length
        ? _week[_selectedIndex]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchAttendanceHistory,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                _buildHeader(),
                const SizedBox(height: 18),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            color: const Color(0xFFB91C1C),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _fetchAttendanceHistory,
                          child: Text(
                            'Tap to retry',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _buildMonthCard(),
                  const SizedBox(height: 16),
                  _buildOverviewGrid(),
                  const SizedBox(height: 22),
                  Text(
                    'Attendance History',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_week.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'No attendance records found',
                          style: GoogleFonts.inter(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    _buildWeekRow(),
                    const SizedBox(height: 16),
                    if (selected != null) _buildSelectedDayCard(selected),
                  ],
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Attendance',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        GestureDetector(
          onTap: _fetchAttendanceHistory,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthCard() {
    final percentage = (_stats['percentage'] as num?)?.toDouble() ?? 0.0;
    final present = _stats['present'] ?? 0;
    final totalDays = _stats['total_days'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight2.withValues(alpha: 0.75),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 66,
            height: 66,
            child: Stack(
              children: [
                SizedBox.expand(child: CustomPaint(painter: _RingPainter(percentage))),
                Center(
                  child: Text(
                    '${percentage.toStringAsFixed(percentage.truncateToDouble() == percentage ? 0 : 1)}%',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This month',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$present of $totalDays working days',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '🔥 Attendance Active',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid() {
    final stats = [
      {'icon': Icons.check_circle_outline_rounded, 'value': _stats['present'].toString().padLeft(2, '0'), 'label': 'Present'},
      {'icon': Icons.highlight_off_rounded, 'value': _stats['absent'].toString().padLeft(2, '0'), 'label': 'Absent'},
      {'icon': Icons.schedule_rounded, 'value': _stats['late'].toString().padLeft(2, '0'), 'label': 'Late'},
      {'icon': Icons.event_available_rounded, 'value': _stats['total_days'].toString().padLeft(2, '0'), 'label': 'Total'},
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      childAspectRatio: 0.75,
      children: stats.map((s) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(s['icon'] as IconData, color: AppColors.primaryDark, size: 18),
              const SizedBox(height: 6),
              Text(
                s['value'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                s['label'] as String,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: AppColors.primary.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeekRow() {
    final items = List.generate(_week.length, (i) {
      final d = _week[i];
      final isSelected = i == _selectedIndex;
      final color = _statusColor(d['status']);
      return GestureDetector(
        onTap: () => setState(() => _selectedIndex = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 58,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isSelected ? 0.25 : 0.06),
                blurRadius: isSelected ? 14 : 8,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                d['label'],
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppColors.muted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                d['date'],
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      );
    });

    if (_week.length <= 5) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: item,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSelectedDayCard(Map<String, dynamic> d) {
    final color = _statusColor(d['status']);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
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
                d['full'],
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Text(
                  d['tag'],
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['checkIn'],
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Check In',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.border),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['checkOut'],
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Check Out',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  _RingPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final bg = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bg);
    final fg = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final angle = (percentage / 100) * 2 * 3.14159;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      angle,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.percentage != percentage;
}