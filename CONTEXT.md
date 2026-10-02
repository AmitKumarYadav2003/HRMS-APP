# HRMS Flutter App — Project Context

> Is file ko pehle padho taaki poora project-context mil jaye, dobara explain karne ki zaroorat na pade.

## Project Overview
Real HRMS (Human Resource Management System) Flutter app, employee-facing (admin panel nahi). Frontend/UI poori tarah complete hai, dummy/hardcoded data ke saath. Ab **backend (Laravel + MySQL)** integrate karna hai.

## Tech Stack (Finalized)
| Layer | Technology | Notes |
|---|---|---|
| **Frontend** | Flutter (Dart) | Already complete — 9+ screens |
| **Backend** | Laravel (PHP) | REST API only — no Blade views, JSON responses |
| **Database** | MySQL | Already familiar (used in investor project) |
| **Connection** | Dio package | Flutter ↔ Laravel API calls |
| **Auth** | Laravel Sanctum | Token-based API authentication |

> **Firebase approach was dropped** — Laravel+MySQL is faster to build and reuses existing skills.

## Design System (main.dart → AppColors class)
```dart
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
```
**Rule:** Kabhi bhi naya hex hardcode mat karo — hamesha `AppColors.xxx` use karo. Sirf universal status-colors (green=success, red=danger, amber=warning) hardcoded rehte hain, yeh theek hai.

**Fonts:** `google_fonts` package — `GoogleFonts.poppins()` headings ke liye, `GoogleFonts.inter()` body text ke liye. Kabhi `fontFamily: 'Poppins'` string wala purana tarika use mat karna (kaam nahi karta).

**Color usage philosophy:** Navy = primary actions/hero cards. Sky-blue tint = informational/stat cards. Orange = sparingly, sirf primary CTA buttons ya urgent highlights ke liye (max 1-2 per screen).

**Deprecated API:** `.withOpacity()` deprecated hai — hamesha `.withValues(alpha: x)` use karo.

## Folder Structure — Flutter App
```
lib/
├── main.dart              (AppColors, ThemeData, HRMSApp, entry point)
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── attendance_screen.dart      ✅ UI REDESIGNED (gradient hero, progress ring, timeline)
│   ├── leave_screen.dart           (tabs: My Leaves / Apply Leave / Leave Balance)
│   ├── apply_leave_screen.dart
│   ├── payslip_screen.dart         (list + detail view toggle)
│   ├── profile_screen.dart
│   ├── holiday_calendar_screen.dart
│   ├── notifications_screen.dart
│   ├── search_screen.dart
│   ├── reports_screen.dart
│   └── announcements_screen.dart
├── widgets/
│   ├── dashboard_top_bar.dart
│   ├── hero_checkin_card.dart      (contains SlideToPunch)
│   ├── slide_to_punch.dart         (reusable — used in Dashboard + Attendance)
│   ├── quick_actions_row.dart      (8 actions, "View all" expands from 4→8)
│   ├── stats_overview_card.dart
│   ├── streak_card.dart
│   ├── announcements_section.dart
│   ├── upcoming_holiday_card.dart
│   └── bottom_nav_bar.dart
├── services/                       [TO BE CREATED]
│   ├── api_service.dart            (Dio base client — base URL, headers, token)
│   ├── auth_service.dart           (login, logout, token storage)
│   ├── attendance_service.dart     (check-in/out, fetch records)
│   ├── leave_service.dart          (apply leave, fetch leaves)
│   └── payslip_service.dart        (fetch payslips)
├── models/                         [TO BE CREATED]
│   ├── user_model.dart
│   ├── attendance_model.dart
│   ├── leave_model.dart
│   └── payslip_model.dart
└── utils/

## Screens Status — All UI Complete (dummy data)
| Screen | Status | Notes |
|---|---|---|
| Splash | ✅ Done | Auto-navigates to Login after delay |
| Login | ✅ Done (dummy credentials pre-filled for dev speed) | Needs real Firebase Auth |
| Dashboard | ✅ Done | Hero check-in, stats, announcements, quick actions, holiday |
| Attendance | ✅ Done | Status card (Check In/Out), Overview grid, week strip (tap to view day) |
| Leave | ✅ Done | 3 tabs: My Leaves (timeline history), Apply Leave (form), Leave Balance (progress bars) |
| Payslip | ✅ Done | List → tap → detail with earnings/deductions breakdown |
| Profile | ✅ Done | Header card, quick stats, personal info, settings list, logout |
| Holiday Calendar | ✅ Done | Next-holiday hero + past/upcoming list |
| Notifications, Search, Reports, Announcements | ✅ Done | Supporting screens |

## Key Implementation Patterns
- **Navigation:** Bottom-nav tabs (Home/Attendance/Leave/Payslip/Profile) managed via `IndexedStack`-like pattern in `dashboard_screen.dart` (`_currentIndex` state). Other screens pushed via `Navigator.push(context, slideRoute(...))` custom transition.
- **SlideToPunch widget:** Custom drag-gesture widget, reused in Dashboard hero card and Attendance screen. Takes `punched` (bool) and `onComplete` (callback) and optional `isDark` param for background contrast.
- **State management:** Currently plain `StatefulWidget` + `setState()` everywhere — NO provider/riverpod/bloc yet. Will need proper state management once Firebase data flows in.
- **Not yet built:** Change Password / Change PIN screens (placeholders only, `onTap: () {}`).

## What's Pending (Next Steps)
1. **Firebase setup:** Authentication (email/password) + Cloud Firestore (collections: `users`, `attendance`, `leaves`, `payslips`, `announcements`, `holidays`)
2. Replace all dummy/hardcoded data across screens with real Firestore reads
3. Add proper state management (Provider or Riverpod recommended) once real data flows in
4. Build Change Password / Change PIN screens
5. Consider: push notifications (flutter_local_notifications), biometric app-lock (local_auth) — discussed but deprioritized until backend is solid

## Developer Context
Person is a web-dev background developer, beginner in Flutter and backend/Firebase. Prefers step-by-step guidance with short explanations of new concepts (not full theory dumps). Prefers concise code diffs (only changed lines + context) rather than full file dumps once a file is already established, to conserve conversation/token budget.
