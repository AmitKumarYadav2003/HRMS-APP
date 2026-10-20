import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/announcement_model.dart';
import '../screens/announcements_screen.dart';
import '../services/announcement_service.dart';
import '../utils/page_transitions.dart';

class AnnouncementsSection extends StatefulWidget {
  const AnnouncementsSection({super.key});

  @override
  State<AnnouncementsSection> createState() => _AnnouncementsSectionState();
}

class _AnnouncementsSectionState extends State<AnnouncementsSection> {
  final AnnouncementService _service = AnnouncementService();

  bool _isLoading = true;
  String? _error;
  List<Announcement> _announcements = [];

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
      final items = await _service.fetchAnnouncements(limit: 2);
      if (!mounted) return;
      setState(() {
        _announcements = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Announcements load nahi ho paaye';
        _isLoading = false;
      });
    }
  }

  // Type ke hisaab se icon aur color
  ({IconData icon, Color color, Color bg}) _styleFor(String type) {
    switch (type) {
      case 'event':
        return (
          icon: Icons.groups_rounded,
          color: const Color(0xFF10B981),
          bg: const Color(0xFFDCFCE7),
        );
      case 'policy':
        return (
          icon: Icons.description_outlined,
          color: const Color(0xFFF59E0B),
          bg: const Color(0xFFFEF3C7),
        );
      default:
        return (
          icon: Icons.campaign_outlined,
          color: AppColors.orange,
          bg: AppColors.orangeLight,
        );
    }
  }

  void _openAll() {
    Navigator.push(context, slideRoute(const AnnouncementsScreen()));
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const SizedBox(
        height: 70,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_error != null) {
      return GestureDetector(
        onTap: _load,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.refresh_rounded, color: AppColors.muted, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$_error. Tap karke dobara try karo.',
                  style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_announcements.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'No announcements available.',
          style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.muted),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < _announcements.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _AnnouncementTile(
            announcement: _announcements[i],
            style: _styleFor(_announcements[i].type),
            onTap: _openAll,
          ),
        ],
      ],
    );
  }

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
              Text(
                'Announcements',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text),
              ),
              GestureDetector(
                onTap: _openAll,
                child: Text(
                  'See all',
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBody(),
        ],
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final Announcement announcement;
  final ({IconData icon, Color color, Color bg}) style;
  final VoidCallback onTap;

  const _AnnouncementTile({
    required this.announcement,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.07), blurRadius: 12),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: style.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(style.icon, color: style.color, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    announcement.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.border, size: 20),
          ],
        ),
      ),
    );
  }
}