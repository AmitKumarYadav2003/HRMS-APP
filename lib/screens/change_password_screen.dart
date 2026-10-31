import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../services/password_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  bool _saving = false;
  bool _hideCurrent = true, _hideNew = true, _hideConfirm = true;
  String? _currentErr, _newErr, _confirmErr, _serverErr;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _currentErr = _current.text.isEmpty ? 'Current password is required' : null;
      _newErr = _new.text.length < 8 ? 'Password must be at least 8 characters' : null;
      _confirmErr = _confirm.text != _new.text ? 'Password does not match' : null;
      _serverErr = null;
    });

    if (_currentErr != null || _newErr != null || _confirmErr != null) return;

    setState(() => _saving = true);
    try {
      await PasswordService().changePassword(_current.text, _new.text, _confirm.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password successfully changed')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _serverErr = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController controller,
    bool hidden,
    VoidCallback onToggle,
    String? error,
  ) {
    return TextField(
      controller: controller,
      obscureText: hidden,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.muted,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              Row(
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
                    'Change Password',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'At least 8 characters.',
                style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              _field('Current Password', _current, _hideCurrent,
                  () => setState(() => _hideCurrent = !_hideCurrent), _currentErr),
              const SizedBox(height: 14),
              _field('New Password', _new, _hideNew,
                  () => setState(() => _hideNew = !_hideNew), _newErr),
              const SizedBox(height: 14),
              _field('Confirm New Password', _confirm, _hideConfirm,
                  () => setState(() => _hideConfirm = !_hideConfirm), _confirmErr),
              if (_serverErr != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _serverErr!,
                          style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFFEF4444)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Update Password',
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}