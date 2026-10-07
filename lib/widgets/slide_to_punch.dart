import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class SlideToPunch extends StatefulWidget {
  final bool punched;
  final String? label;
  final bool isCompleted;
  final VoidCallback onComplete;
  final bool isDark;

  const SlideToPunch({
    super.key,
    required this.punched,
    required this.onComplete,
    this.label,
    this.isCompleted = false,
    this.isDark = true,
  });

  @override
  State<SlideToPunch> createState() => _SlideToPunchState();
}

class _SlideToPunchState extends State<SlideToPunch> {
  double _drag = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.isCompleted) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label ?? 'Completed for Today',
                style: GoogleFonts.inter(
                  color: const Color(0xFF047857),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayText = widget.label ??
        (widget.punched ? 'Slide to Punch Out' : 'Slide to Punch In');

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - 56;
        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Text(
                  displayText,
                  style: GoogleFonts.inter(
                    color: widget.isDark ? Colors.white : AppColors.primaryDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOut,
                left: _drag,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(
                      () =>
                          _drag = (_drag + details.delta.dx).clamp(0, maxDrag),
                    );
                  },
                  onHorizontalDragEnd: (details) {
                    if (_drag > maxDrag * 0.7) {
                      widget.onComplete();
                    }
                    setState(() => _drag = 0);
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: (_drag > maxDrag * 0.85)
                          ? const Color(0xFF10B981)
                          : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      color: (_drag > maxDrag * 0.85)
                          ? Colors.white
                          : AppColors.primary,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
