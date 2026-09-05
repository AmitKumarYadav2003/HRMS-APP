import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../screens/announcements_screen.dart';
import '../utils/page_transitions.dart';

class AnnouncementsSection extends StatelessWidget {
  const AnnouncementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Announcements', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
              GestureDetector(
                onTap: () => Navigator.push(context, slideRoute(const AnnouncementsScreen())),
                child: Text('See all', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(context, slideRoute(const AnnouncementsScreen())),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 12)]),
              child: Row(
                children: [
                  Container(
  width: 38,
  height: 38,
  decoration: BoxDecoration(color: AppColors.orangeLight, borderRadius: BorderRadius.circular(10)),
  child: const Icon(Icons.shield_outlined, color: AppColors.orange, size: 17),
),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Open enrollment is live!', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text)),
                        Text('Review your benefits before Sep 1.', style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.border, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}