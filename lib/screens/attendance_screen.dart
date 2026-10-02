import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _selectedIndex = 2;

  final List<Map<String, dynamic>> _week = [
    {'label': 'Mon', 'date': '17', 'status': 'present', 'full': 'Monday, 17 Aug', 'checkIn': '09:05 AM', 'checkOut': '06:10 PM', 'tag': 'On Time'},
    {'label': 'Tue', 'date': '18', 'status': 'present', 'full': 'Tuesday, 18 Aug', 'checkIn': '09:01 AM', 'checkOut': '06:05 PM', 'tag': 'On Time'},
    {'label': 'Wed', 'date': '19', 'status': 'late', 'full': 'Wednesday, 19 Aug', 'checkIn': '09:02 AM', 'checkOut': '--:--', 'tag': 'Late'},
    {'label': 'Thu', 'date': '20', 'status': 'absent', 'full': 'Thursday, 20 Aug', 'checkIn': '--:--', 'checkOut': '--:--', 'tag': 'Absent'},
    {'label': 'Fri', 'date': '21', 'status': 'present', 'full': 'Friday, 21 Aug', 'checkIn': '08:58 AM', 'checkOut': '06:02 PM', 'tag': 'On Time'},
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'present': return const Color(0xFF10B981);
      case 'absent': return const Color(0xFFEF4444);
      case 'late': return AppColors.orange;
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
              _buildMonthCard(),
              const SizedBox(height: 16),
              _buildOverviewGrid(),
              const SizedBox(height: 22),
              Text('This Week', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text)),
              const SizedBox(height: 12),
              _buildWeekRow(),
              const SizedBox(height: 16),
              _buildSelectedDayCard(selected),
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

  Widget _buildMonthCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight2.withOpacity(0.75)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 66, height: 66,
            child: Stack(
              children: [
                SizedBox.expand(child: CustomPaint(painter: _RingPainter(96))),
                Center(child: Text('96%', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This month', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text('18 of 21 working days', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(999)),
                  child: Text('🔥 12-day streak', style: GoogleFonts.inter(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700)),
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
      {'icon': Icons.check_circle_outline_rounded, 'value': '18', 'label': 'Present'},
      {'icon': Icons.highlight_off_rounded, 'value': '01', 'label': 'Absent'},
      {'icon': Icons.schedule_rounded, 'value': '02', 'label': 'Late'},
      {'icon': Icons.event_available_rounded, 'value': '21', 'label': 'Total'},
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
          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(s['icon'] as IconData, color: AppColors.primaryDark, size: 18),
              const SizedBox(height: 6),
              Text(s['value'] as String, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
              Text(s['label'] as String, style: GoogleFonts.inter(fontSize: 9, color: AppColors.primary.withOpacity(0.75), fontWeight: FontWeight.w600)),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 58,
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

  Widget _buildSelectedDayCard(Map<String, dynamic> d) {
    final color = _statusColor(d['status']);
    return Container(
      padding: const EdgeInsets.all(16),
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
                    Text(d['checkIn'], style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text)),
                    const SizedBox(height: 3),
                    Text('Check In', style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.border),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d['checkOut'], style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text)),
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
}

class _RingPainter extends CustomPainter {
  final double percentage;
  _RingPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final bg = Paint()..color = Colors.white.withOpacity(0.2)..strokeWidth = 5..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bg);
    final fg = Paint()..color = Colors.white..strokeWidth = 5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final angle = (percentage / 100) * 2 * 3.14159;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14159 / 2, angle, false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.percentage != percentage;
}