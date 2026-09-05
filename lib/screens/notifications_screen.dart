import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {'icon': Icons.check_circle_rounded, 'color': const Color(0xFF10B981), 'title': 'Leave Approved', 'msg': 'Your Sick Leave (10 Jun) has been approved.', 'time': '2h ago', 'unread': true},
      {'icon': Icons.campaign_rounded, 'color': AppColors.orange, 'title': 'New Announcement', 'msg': 'Open enrollment is live! Review benefits before Sep 1.', 'time': '5h ago', 'unread': true},
      {'icon': Icons.cancel_rounded, 'color': const Color(0xFFEF4444), 'title': 'Leave Rejected', 'msg': 'Your Annual Leave request (16 Dec) was rejected.', 'time': '1d ago', 'unread': false},
      {'icon': Icons.receipt_long_rounded, 'color': AppColors.primary, 'title': 'Payslip Generated', 'msg': 'Your August 2026 payslip is ready to view.', 'time': '2d ago', 'unread': false},
      {'icon': Icons.event_rounded, 'color': const Color(0xFFF59E0B), 'title': 'Upcoming Holiday', 'msg': 'Ganesh Chaturthi on 17 Sep. Plan accordingly.', 'time': '3d ago', 'unread': false},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: notifications.length,
                itemBuilder: (context, index) => _notificationTile(notifications[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chevron_left_rounded, color: AppColors.primaryDark, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Text('Notifications', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
        ],
      ),
    );
  }

  Widget _notificationTile(Map<String, dynamic> n) {
    final bool unread = n['unread'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: unread ? AppColors.accent : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: (n['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n['title'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(height: 3),
                Text(n['msg'] as String, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.muted, height: 1.3)),
                const SizedBox(height: 6),
                Text(n['time'] as String, style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (unread) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}