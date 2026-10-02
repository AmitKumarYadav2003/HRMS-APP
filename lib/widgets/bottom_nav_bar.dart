import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.schedule_rounded, 'label': 'Attendance'},
      {'icon': Icons.article_rounded, 'label': 'Leave'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Payslip'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Padding(
padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 25),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
  color: AppColors.card,
  borderRadius: BorderRadius.circular(26),
  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 10))],
),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isActive = currentIndex == index;
            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 12, vertical: 10),
                decoration: BoxDecoration(
  gradient: LinearGradient(
    colors: isActive
        ? [AppColors.primary, AppColors.primaryLight2]
        : [Colors.transparent, Colors.transparent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: BorderRadius.circular(18),
),
                child: isActive
    ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(items[index]['icon'] as IconData, color: Colors.white, size: 19),
          const SizedBox(width: 6),
          Text(items[index]['label'] as String, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      )
    : Icon(items[index]['icon'] as IconData, color: AppColors.muted, size: 20),
              ),
            );
          }),
        ),
      ),
    );
  }
}