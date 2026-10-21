import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  static const int _perPage = 10;

  final AnnouncementService _service = AnnouncementService();
  final ScrollController _scrollController = ScrollController();

  final List<Announcement> _items = [];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNextPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _error = null;
    });

    try {
      final page = await _service.fetchAnnouncements(
        page: _currentPage + 1,
        perPage: _perPage,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _currentPage = page.currentPage;
        _hasMore = page.hasMore;
        _isLoadingMore = false;
        _isInitialLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Announcements could not be loaded.';
        _isLoadingMore = false;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _currentPage = 0;
      _hasMore = true;
      _isInitialLoading = true;
    });
    await _loadNextPage();
  }

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

  Widget _message(String text, {VoidCallback? onTap}) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_error != null) {
      return GestureDetector(
        onTap: _loadNextPage,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              '$_error. Tap to retry.',
              style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.muted),
            ),
          ),
        ),
      );
    }
    if (!_hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No more announcements.',
            style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.muted),
          ),
        ),
      );
    }
    return const SizedBox(height: 20);
  }

  Widget _buildBody() {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return _error != null
          ? _message('$_error. Tap and retry.', onTap: _refresh)
          : _message('No announcements available.');
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          if (index == _items.length) return _buildFooter();
          final a = _items[index];
          return _AnnouncementCard(announcement: a, style: _styleFor(a.type));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Announcements',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final ({IconData icon, Color color, Color bg}) style;

  const _AnnouncementCard({required this.announcement, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 10),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(style.icon, color: style.color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
                ),
                const SizedBox(height: 3),
                Text(
                  announcement.body,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  '${announcement.postedBy ?? 'Admin'} · ${announcement.createdAt}',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}