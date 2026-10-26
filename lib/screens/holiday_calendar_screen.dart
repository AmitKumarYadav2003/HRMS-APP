import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/holiday_model.dart';
import '../services/holiday_service.dart';

class HolidayCalendarScreen extends StatefulWidget {
  const HolidayCalendarScreen({super.key});

  @override
  State<HolidayCalendarScreen> createState() => _HolidayCalendarScreenState();
}

class _HolidayCalendarScreenState extends State<HolidayCalendarScreen> {
  final HolidayService _service = HolidayService();

  bool _isLoading = true;
  String? _error;
  List<Holiday> _past = [];
  List<Holiday> _upcoming = [];
  Holiday? _next;
  int _daysToNext = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final all = await _service.fetchHolidays();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Aaj se pehle wali holidays = past (latest pehle)
      final past = all.where((h) => h.date.isBefore(today)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      // Aaj ya aage wali holidays = upcoming (nearest pehle)
      final upcoming = all.where((h) => !h.date.isBefore(today)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      final next = upcoming.isNotEmpty ? upcoming.first : null;
      final daysToNext = next == null ? 0 : next.date.difference(today).inDays;

      if (!mounted) return;
      setState(() {
        _past = past;
        _upcoming = upcoming;
        _next = next;
        _daysToNext = daysToNext;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Holidays load nahi ho paaye.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                _buildHeader(context),
                const SizedBox(height: 18),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  _buildError()
                else ...[
                  _buildNextHolidayHero(),
                  const SizedBox(height: 20),
                  _sectionLabel('Recently Observed'),
                  const SizedBox(height: 10),
                  if (_past.isEmpty)
                    _emptyText('Abhi koi past holiday nahi hai')
                  else
                    ..._past.map((h) => _holidayItem(h, isPast: true)),
                  const SizedBox(height: 20),
                  _sectionLabel('Upcoming'),
                  const SizedBox(height: 10),
                  if (_upcoming.isEmpty)
                    _emptyText('Koi upcoming holiday nahi hai')
                  else
                    ..._upcoming.map((h) => _holidayItem(h, isPast: false)),
                ],
                const SizedBox(height: 30),
              ],
            ),
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
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_left_rounded, color: AppColors.primaryDark, size: 24),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Holiday Calendar',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
      ],
    );
  }

  Widget _buildNextHolidayHero() {
    final next = _next;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight2, AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NEXT HOLIDAY IN',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              if (next != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _daysToNext == 0 ? 'Aaj' : '$_daysToNext days',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            next?.name ?? 'Koi holiday nahi',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800),
          ),
          if (next != null) ...[
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(next.date),
              style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.65), fontSize: 12.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Text(_error!, style: GoogleFonts.inter(color: AppColors.muted)),
        const SizedBox(height: 10),
        TextButton(onPressed: _load, child: const Text('Retry')),
      ],
    );
  }

  Widget _emptyText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted)),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.6),
    );
  }

  String _tagLabel(String type) {
    switch (type) {
      case 'optional':
        return 'Optional';
      case 'festival':
        return 'Festival';
      default:
        return 'National';
    }
  }

  Color _tagColor(String type) {
    switch (type) {
      case 'optional':
        return const Color(0xFFF59E0B);
      case 'festival':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.primary;
    }
  }

  Widget _holidayItem(Holiday h, {required bool isPast}) {
    final tagColor = _tagColor(h.type);
    final day = DateFormat('d').format(h.date);
    final mon = DateFormat('MMM').format(h.date).toUpperCase();
    final weekday = DateFormat('EEEE').format(h.date);

    return Opacity(
      opacity: isPast ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPast ? AppColors.border.withValues(alpha: 0.5) : AppColors.accent,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isPast ? AppColors.muted : AppColors.primaryDark,
                      height: 1,
                    ),
                  ),
                  Text(
                    mon,
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: isPast ? AppColors.muted : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.name,
                    style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                  Text(weekday, style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
            if (isPast)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  'Past',
                  style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.muted),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: tagColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  _tagLabel(h.type),
                  style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: tagColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}