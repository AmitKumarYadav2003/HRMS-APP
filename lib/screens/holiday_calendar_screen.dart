import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class HolidayCalendarScreen extends StatelessWidget {
  const HolidayCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final past = [
      {'day': '15', 'mon': 'Aug', 'name': 'Independence Day', 'sub': 'Saturday'},
      {'day': '17', 'mon': 'Jul', 'name': 'Muharram', 'sub': 'Friday'},
    ];
    final upcoming = [
      {'day': '17', 'mon': 'Sep', 'name': 'Ganesh Chaturthi', 'sub': 'Thursday', 'tag': 'Optional'},
      {'day': '2', 'mon': 'Oct', 'name': 'Gandhi Jayanti', 'sub': 'Friday', 'tag': 'National'},
      {'day': '20', 'mon': 'Oct', 'name': 'Diwali', 'sub': 'Tuesday', 'tag': 'National'},
      {'day': '25', 'mon': 'Dec', 'name': 'Christmas', 'sub': 'Friday', 'tag': 'Optional'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              _buildHeader(context),
              const SizedBox(height: 18),
              _buildNextHolidayHero(),
              const SizedBox(height: 20),
              _sectionLabel('Recently Observed'),
              const SizedBox(height: 10),
              ...past.map((h) => _holidayItem(h, isPast: true)),
              const SizedBox(height: 20),
              _sectionLabel('Upcoming'),
              const SizedBox(height: 10),
              ...upcoming.map((h) => _holidayItem(h, isPast: false)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
  onTap: () => Navigator.pop(context),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.chevron_left_rounded, color: AppColors.primaryDark, size: 24),
      ),
    ],
  ),
),
        const SizedBox(width: 14),
        Text('Holiday Calendar', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
      ],
    );
  }

  Widget _buildNextHolidayHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryLight2, AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 26, offset: const Offset(0, 14))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NEXT HOLIDAY IN', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.65), fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
              Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
  decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(999)),
  child: Text('23 days', style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
),
            ],
          ),
          const SizedBox(height: 12),
          Text('Ganesh Chaturthi', style: GoogleFonts.poppins(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Thursday, 17 September 2026', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.65), fontSize: 12.5)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.6));
  }

  Widget _holidayItem(Map<String, dynamic> h, {required bool isPast}) {
    final tagColor = h['tag'] == 'Optional' ? const Color(0xFFF59E0B) : AppColors.primary;
    return Opacity(
      opacity: isPast ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 10)]),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: isPast ? AppColors.border.withOpacity(0.5) : AppColors.accent, borderRadius: BorderRadius.circular(13)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(h['day'], style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: isPast ? AppColors.muted : AppColors.primaryDark, height: 1)),
                  Text(h['mon'].toString().toUpperCase(), style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w700, color: isPast ? AppColors.muted : AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h['name'], style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.text)),
                  Text(h['sub'], style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
            if (isPast)
              Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)), child: Text('Past', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.muted)))
            else
              Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: tagColor.withOpacity(0.08), borderRadius: BorderRadius.circular(999), border: Border.all(color: tagColor.withOpacity(0.35))), child: Text(h['tag'], style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: tagColor))),
          ],
        ),
      ),
    );
  }
}