import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../screens/holiday_calendar_screen.dart';
import '../utils/page_transitions.dart';

class UpcomingHolidayCard extends StatelessWidget {
  const UpcomingHolidayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
              GestureDetector(
                onTap: () => Navigator.push(context, slideRoute(const HolidayCalendarScreen())),
                child: Text('View all', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(context, slideRoute(const HolidayCalendarScreen())),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 12)]),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('17', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1)),
                        Text('SEP', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ganesh Chaturthi', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text)),
                        Text('Thursday · Optional Holiday', style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(color: AppColors.orangeLight, borderRadius: BorderRadius.circular(999)),
  child: Text('23 days', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.orange)),
),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}