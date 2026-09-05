import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final announcements = [
      {
        'title': 'Open enrollment is live!',
        'sub': 'Review your benefits before Sep 1.',
        'icon': Icons.shield_outlined,
        'color': AppColors.orange,
      },
      {
        'title': 'Team town hall',
        'sub': 'Join us Thursday at 4:00 PM.',
        'icon': Icons.groups_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'New HR policy update',
        'sub': 'Read the revised leave policy.',
        'icon': Icons.description_outlined,
        'color': const Color(0xFFF59E0B),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
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
                  Text('Announcements', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final a = announcements[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.06),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: (a['color'] as Color).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            a['icon'] as IconData,
                            color: a['color'] as Color,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a['title'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
Text(a['sub'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
