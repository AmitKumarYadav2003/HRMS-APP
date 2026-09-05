import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'slide_to_punch.dart';

class HeroCheckinCard extends StatefulWidget {
  const HeroCheckinCard({super.key});

  @override
  State<HeroCheckinCard> createState() => _HeroCheckinCardState();
}

class _HeroCheckinCardState extends State<HeroCheckinCard> {
  bool _punchedOut = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today's Attendance", style: GoogleFonts.poppins(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w700)),
              Text('Wed, 19 Aug', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryLight2, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Punch In', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('09:02 AM', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Punch Out', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    if (_punchedOut) const Icon(Icons.check_circle_rounded, color: Color(0xFF6EE7B7), size: 15),
    if (_punchedOut) const SizedBox(width: 4),
    Text(
      _punchedOut ? '06:15 PM' : 'Pending',
      style: GoogleFonts.poppins(color: Colors.white, fontSize: _punchedOut ? 20 : 16, fontWeight: _punchedOut ? FontWeight.w800 : FontWeight.w700),
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
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(999)),
            padding: const EdgeInsets.all(4),
            child: SlideToPunch(punched: _punchedOut, onComplete: () => setState(() => _punchedOut = !_punchedOut), isDark: false),
          ),
        ],
      ),
    );
  }
}