import 'package:flutter/material.dart';
import '../widgets/dashboard_top_bar.dart';
import '../widgets/hero_checkin_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/upcoming_holiday_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/attendance_screen.dart';
import '../screens/leave_screen.dart';
import '../screens/payslip_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/announcements_section.dart';
import '../widgets/stats_overview_card.dart';
import '../widgets/streak_card.dart';
import '../main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
  children: [
    Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
  colors: [AppColors.primary.withOpacity(0.9), AppColors.primaryLight2.withOpacity(0.5), AppColors.background.withOpacity(0)],
  stops: const [0.0, 0.4, 1.0],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
),
      ),
    ),
    SafeArea(child: _buildBody()),
  ],
),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  // Method banao yahan
  Widget _buildBody() {
    if (_currentIndex == 0) {
      return _buildDashboard();
    } else if (_currentIndex == 1) {
      return const AttendanceScreen();
    } else if (_currentIndex == 2) {
      return const LeaveScreen();
    }
    else if (_currentIndex == 3) {
      return const PayslipScreen();
    } else if (_currentIndex == 4) {
      return const ProfileScreen();
    }
    return const Center(child: Text('Coming soon'));
  }

  // Dashboard ke saari widgets
  Widget _buildDashboard() {
  return SingleChildScrollView(
    child: Column(
      children: [
  const DashboardTopBar(),
  const SizedBox(height: 12),
 const HeroCheckinCard(),
const SizedBox(height: 4),
const AnnouncementsSection(),
const SizedBox(height: 16),
const QuickActionsRow(),
const SizedBox(height: 12),
const StatsOverviewCard(),
  const SizedBox(height: 12),
  const StreakCard(),
  const SizedBox(height: 8),
  const UpcomingHolidayCard(),
  const SizedBox(height: 20),
],
    ),
  );
}
}
