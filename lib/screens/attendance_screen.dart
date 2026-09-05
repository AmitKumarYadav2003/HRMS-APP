import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _selectedIndex = 2; // Wednesday default

  final List<Map<String, dynamic>> _week = [
    {'label': 'Mon', 'date': '17', 'status': 'present', 'full': 'Monday, 17 Aug', 'checkIn': '09:05 AM', 'checkOut': '06:10 PM', 'tag': 'On Time'},
    {'label': 'Tue', 'date': '18', 'status': 'present', 'full': 'Tuesday, 18 Aug', 'checkIn': '09:01 AM', 'checkOut': '06:05 PM', 'tag': 'On Time'},
    {'label': 'Wed', 'date': '19', 'status': 'present', 'full': 'Wednesday, 19 Aug', 'checkIn': '09:02 AM', 'checkOut': '--:--', 'tag': 'On Time'},
    {'label': 'Thu', 'date': '20', 'status': 'absent', 'full': 'Thursday, 20 Aug', 'checkIn': '--:--', 'checkOut': '--:--', 'tag': 'Absent'},
    {'label': 'Fri', 'date': '21', 'status': 'half', 'full': 'Friday, 21 Aug', 'checkIn': '09:20 AM', 'checkOut': '02:15 PM', 'tag': 'Half-day'},
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'present': return const Color(0xFF10B981);
      case 'absent': return const Color(0xFFEF4444);
      case 'half': return const Color(0xFFF59E0B);
      default: return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _week[_selectedIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              _buildHeader(),
              const SizedBox(height: 18),
              _buildStatusCard(selected),
              const SizedBox(height: 22),
              Text('Overview', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text)),
              const SizedBox(height: 12),
              _buildOverviewGrid(),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('This Week', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text)),
                  Text('View all', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 12),
              _buildWeekRow(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Attendance', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: AppColors.card, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 8)]),
          child: const Icon(Icons.download_rounded, color: AppColors.primary, size: 17),
        ),
      ],
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> d) {
    final color = _statusColor(d['status']);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 12)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(d['full'], style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withOpacity(0.35))),
                child: Text(d['tag'], style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
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
                    Text(d['checkIn'], style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text)),
                    const SizedBox(height: 3),
                    Text('Check In', style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d['checkOut'], style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text)),
                    const SizedBox(height: 3),
                    Text('Check Out', style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid() {
    final stats = [
      {'icon': Icons.check_circle_outline_rounded, 'value': '18', 'label': 'Present Days'},
      {'icon': Icons.highlight_off_rounded, 'value': '01', 'label': 'Absent Days'},
      {'icon': Icons.schedule_rounded, 'value': '02', 'label': 'Late Days'},
      {'icon': Icons.event_available_rounded, 'value': '21', 'label': 'Total Days'},
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.9,
      children: stats.map((s) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                child: Icon(s['icon'] as IconData, color: AppColors.primaryDark, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['value'] as String, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                    Text(s['label'] as String, style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.primary.withOpacity(0.75), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeekRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_week.length, (i) {
        final d = _week[i];
        final isSelected = i == _selectedIndex;
        final color = _statusColor(d['status']);
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = i),
          child: Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(isSelected ? 0.25 : 0.06), blurRadius: isSelected ? 14 : 8)],
            ),
            child: Column(
              children: [
                Text(d['label'], style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected ? Colors.white.withOpacity(0.7) : AppColors.muted)),
                const SizedBox(height: 6),
                Text(d['date'], style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : AppColors.text)),
                const SizedBox(height: 6),
                Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? Colors.white : color)),
              ],
            ),
          ),
        );
      }),
    );
  }
}