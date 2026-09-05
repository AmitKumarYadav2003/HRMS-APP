import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'attendance_screen.dart';
import 'leave_screen.dart';
import 'payslip_screen.dart';
import '../utils/page_transitions.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              _buildHeader(context),
              const SizedBox(height: 20),
              _reportCard(
                context,
                Icons.calendar_today_rounded,
                'Attendance Report',
                'View monthly attendance summary',
                AppColors.primary,
                const AttendanceScreen(),
              ),
              const SizedBox(height: 12),
              _reportCard(
                context,
                Icons.beach_access_rounded,
                'Leave Report',
                'Track leave usage and balance',
                const Color(0xFF10B981),
                const LeaveScreen(),
              ),
              const SizedBox(height: 12),
              _reportCard(
                context,
                Icons.receipt_long_rounded,
                'Payslip Report',
                'Download salary statements',
                const Color(0xFFF59E0B),
                const PayslipScreen(),
              ),
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Reports',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _reportCard(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    Color color,
    Widget target,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(context, slideRoute(target)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
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
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
