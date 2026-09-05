import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const HRMSApp());
}

class HRMSApp extends StatelessWidget {
  const HRMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HRMS',
      theme: ThemeData(
  useMaterial3: true,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  textTheme: GoogleFonts.interTextTheme(),
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    surfaceTint: Colors.transparent,
  ),
  cardColor: AppColors.card,
),
      home: const SplashScreen(),
    );
  }
}

/// ---------------- Design tokens (reuse everywhere) ----------------

// class AppColors {
//   static const primary = Color(0xFF6366F1);
//   static const primaryDark = Color(0xFF4338CA);
//   static const primaryLight = Color(0xFFEDE9FE);
//   static const background = Color(0xFFEEF2F7);
//   static const card = Colors.white;
//   static const text = Color(0xFF1F2937);
//   static const muted = Color(0xFF6B7280);
//   static const border = Color(0xFFE4E9F0);
// }


// class AppColors {
//   static const primary = Color(0xFF2E5FE8);
//   static const primaryDark = Color(0xFF0B1330);
//   static const primaryLight = Color(0xFFE7EDFC);
//   static const background = Color(0xFFEEF2F7);
//   static const card = Colors.white;
//   static const text = Color(0xFF1F2937);
//   static const muted = Color(0xFF6B7280);
//   static const border = Color(0xFFE4E9F0);
// }
class AppColors {
  static const primary = Color(0xFF2E86DE);
  static const primaryLight2 = Color(0xFF56CCF2);
  static const primaryDark = Color(0xFF1B4F72);
  static const accent = Color(0xFFEAF6FD);
  static const accentBlue = Color(0xFF2E86DE);
  static const orange = Color(0xFFF2994A);
  static const orangeLight = Color(0xFFFFF1E4);
  static const primaryLight = Color(0xFFEAF2FA);
  static const background = Color(0xFFFAFAFA);
  static const card = Colors.white;
  static const text = Color(0xFF1A1D29);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
}