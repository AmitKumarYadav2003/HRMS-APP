import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class ApplyLeaveScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ApplyLeaveScreen({
    super.key,
    this.onBack,
  });

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  int _selectedType = 0;
  final List<String> _leaveTypes = ['Casual', 'Sick', 'Earned', 'Unpaid'];
  DateTime? _fromDate;
  DateTime? _toDate;
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  int get _totalDays {
    if (_fromDate == null || _toDate == null) return 0;
    return _toDate!.difference(_fromDate!).inDays + 1;
  }

  void _resetForm() {
    setState(() {
      _selectedType = 0;
      _fromDate = null;
      _toDate = null;
      _reasonController.clear();
    });
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSectionLabel('Leave type'),
              const SizedBox(height: 10),
              _buildTypeChips(),
              const SizedBox(height: 18),
              _buildSectionLabel('From date'),
              const SizedBox(height: 8),
              _buildDateField(true),
              const SizedBox(height: 14),
              _buildSectionLabel('To date'),
              const SizedBox(height: 8),
              _buildDateField(false),
              if (_totalDays > 0) ...[
                const SizedBox(height: 12),
                _buildTotalDaysPill(),
              ],
              const SizedBox(height: 18),
              _buildSectionLabel('Reason'),
              const SizedBox(height: 8),
              _buildReasonField(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => widget.onBack,
          child: Container(
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
        ),
        const SizedBox(width: 14),
        const Text(
          'Apply Leave',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      ),
    );
  }

  Widget _buildTypeChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_leaveTypes.length, (index) {
        final isSelected = _selectedType == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              _leaveTypes[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.text,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDateField(bool isFrom) {
    final date = isFrom ? _fromDate : _toDate;
    return GestureDetector(
      onTap: () => _pickDate(isFrom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              date == null
                  ? 'Select date'
                  : '${date.day}/${date.month}/${date.year}',
              style: TextStyle(
                fontSize: 14,
                color: date == null ? AppColors.muted : AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalDaysPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Total: $_totalDays day${_totalDays > 1 ? 's' : ''}',
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildReasonField() {
    return TextField(
      controller: _reasonController,
      maxLines: 4,
      style: const TextStyle(fontSize: 14, color: AppColors.text),
      decoration: InputDecoration(
        hintText: 'Write a short reason...',
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 4,
        ),
        onPressed: _isLoading ? null : _submitLeave,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Text(
                'Submit Request',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  Future<void> _submitLeave() async {
    if (_fromDate == null || _toDate == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('http://192.168.1.22:8000/api/leave/apply'),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'from_date': _fromDate.toString().split(' ')[0],
          'to_date': _toDate.toString().split(' ')[0],
          'leave_type': _leaveTypes[_selectedType],
          'reason': _reasonController.text,
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response.statusCode == 200 || response.statusCode == 201) {
          _resetForm();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Leave request submitted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error submitting leave')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class ApplyLeaveEmbedded extends StatelessWidget {
  const ApplyLeaveEmbedded({super.key});

  @override
  Widget build(BuildContext context) {
    return const ApplyLeaveScreen();
  }
}