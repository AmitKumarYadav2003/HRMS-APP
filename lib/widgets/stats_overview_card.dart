import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class StatsOverviewCard extends StatelessWidget {
  const StatsOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
            const SizedBox(height: 14),
            Row(
              children: [
                _statItem('12', 'Leave Balance'),
                _divider(),
                _statItem('96%', 'Attendance'),
                _divider(),
                _statItem('02', 'Pending'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 34, color: AppColors.accentBlue.withOpacity(0.25));
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
          const SizedBox(height: 3),
          Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.primary.withOpacity(0.8))),
        ],
      ),
    );
  }
}