import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.orangeLight, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.local_fire_department_rounded, color: AppColors.orange, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('12-day streak!', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF8A4A16))),
                  const SizedBox(height: 2),
                  Text('Keep it up — best this year', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8A4A16).withOpacity(0.75))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}