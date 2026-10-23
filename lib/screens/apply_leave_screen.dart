import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
// import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../config/api_config.dart';

class ApplyLeaveScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Map<String, dynamic> leaveBalance;

  const ApplyLeaveScreen({
    super.key,
    this.onBack,
    required this.leaveBalance,
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
      _attachedFile = null;
    });
  }

 PlatformFile? _attachedFile;

Future<void> _pickFile() async {
  try {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    
    );

    if (!mounted || files.isEmpty) return;

    setState(() {
      _attachedFile = files.first;
    });
  } catch (e) {
    debugPrint('File picker error: $e');
  }
}

  
Future<void> _pickDate(bool isFrom) async {
  final today = DateUtils.dateOnly(DateTime.now());

  // From date: today se pehle select nahi kar sakte.
  // To date: from date selected hai toh usse pehle select nahi kar sakte.
  final firstAllowedDate = isFrom
      ? today
      : (_fromDate != null && _fromDate!.isAfter(today)
          ? _fromDate!
          : today);

  final currentDate = isFrom ? _fromDate : _toDate;

  final picked = await showDatePicker(
    context: context,
    initialDate: currentDate != null &&
            !currentDate.isBefore(firstAllowedDate)
        ? currentDate
        : firstAllowedDate,
    firstDate: firstAllowedDate,
    lastDate: DateTime(2027, 12, 31),
    selectableDayPredicate: (day) {
      return !DateUtils.dateOnly(day).isBefore(firstAllowedDate);
    },
  );

  if (picked != null) {
    setState(() {
      if (isFrom) {
        _fromDate = picked;

        // From date change ho toh invalid To date clear kar do.
        if (_toDate != null && _toDate!.isBefore(picked)) {
          _toDate = null;
        }
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
              _buildSectionLabel('Attach file (optional)'),
              const SizedBox(height: 8),
              _buildAttachmentField(),
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
        onTap: () {
          if (widget.onBack != null) {
            widget.onBack!.call();
          } else {
            Navigator.pop(context);
          }
        },
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
      Text(
        'Apply Leave',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
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
  final icons = [
    Icons.beach_access_rounded,
    Icons.medical_services_rounded,
    Icons.event_available_rounded,
    Icons.money_off_rounded,
  ];

  final colors = [
    const Color(0xFF4F46E5),
    const Color(0xFF0D9488),
    const Color(0xFF2563EB),
    const Color(0xFF64748B),
  ];

  int getBalance(int index) {
    switch (_leaveTypes[index]) {
      case 'Earned':
        return widget.leaveBalance['Earned'] ?? 0;
      case 'Sick':
        return widget.leaveBalance['Sick'] ?? 0;
      case 'Casual':
        return widget.leaveBalance['Casual'] ?? 0;
      default:
        return 0;
    }
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: colors[_selectedType].withValues(alpha: 0.35),
      ),
      boxShadow: [
        BoxShadow(
          color: colors[_selectedType].withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: _selectedType,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: colors[_selectedType],
          size: 28,
        ),
        borderRadius: BorderRadius.circular(16),
        dropdownColor: AppColors.card,
        selectedItemBuilder: (context) {
          return List.generate(_leaveTypes.length, (index) {
            final balance = getBalance(index);

            return Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors[index].withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icons[index],
                    color: colors[index],
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _leaveTypes[index],
                        style: GoogleFonts.inter(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        index == 3
                            ? 'No balance limit'
                            : 'Leave type',
                        style: GoogleFonts.inter(
                          color: AppColors.text.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != 3)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors[index].withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$balance days available',
                      style: GoogleFonts.inter(
                        color: colors[index],
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            );
          });
        },
        items: List.generate(_leaveTypes.length, (index) {
          final balance = getBalance(index);

          return DropdownMenuItem<int>(
            value: index,
            child: Row(
              children: [
                Icon(icons[index], color: colors[index], size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(_leaveTypes[index])),
                if (index != 3)
                  Text(
                    '$balance days',
                    style: GoogleFonts.inter(
                      color: colors[index],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          );
        }),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedType = value);
          }
        },
      ),
    ),
  );
}

Widget _successDetail(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.muted,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ),
    ],
  );
}

Widget _buildDateField(bool isFrom) {
  final date = isFrom ? _fromDate : _toDate;

  return InkWell(
    onTap: () => _pickDate(isFrom),
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: date != null
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryLight2.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isFrom ? 'From date' : 'To date',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date == null
                      ? 'Select date'
                      : '${date.day.toString().padLeft(2, '0')}/'
                        '${date.month.toString().padLeft(2, '0')}/'
                        '${date.year}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: date == null ? AppColors.muted : AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: 24,
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
  if (_fromDate == null ||
      _toDate == null ||
      _toDate!.isBefore(_fromDate!) ||
      _reasonController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please check all fields and dates')),
    );
    return;
  }

  
  final selectedLeaveType = _leaveTypes[_selectedType];

  int requestedDays = 0;
  for (DateTime day = _fromDate!;
      !day.isAfter(_toDate!);
      day = day.add(const Duration(days: 1))) {
    if (day.weekday != DateTime.sunday) {
      requestedDays++;
    }
  }

  if (selectedLeaveType != 'Unpaid') {
    final availableBalance =
        (widget.leaveBalance[selectedLeaveType] as num?)?.toInt() ?? 0;

    if (requestedDays > availableBalance) {
      showDialog(
  context: context,
  barrierDismissible: true,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              size: 42,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Insufficient Leave Balance',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You requested $requestedDays days, but only '
            '$availableBalance days are available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    ),
  ),
);
      return;
    }
  }

  setState(() => _isLoading = true);

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/leave/apply'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll({
      'from_date': _fromDate!.toIso8601String().split('T')[0],
      'to_date': _toDate!.toIso8601String().split('T')[0],
      'leave_type': _leaveTypes[_selectedType],
      'reason': _reasonController.text.trim(),
    });

    if (_attachedFile != null) {
  final fileBytes = await _attachedFile!.xFile.readAsBytes();

  request.files.add(
    http.MultipartFile.fromBytes(
      'attachment',
      fileBytes,
      filename: _attachedFile!.name,
    ),
  );
}

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (!mounted) return;

    
if (response.statusCode == 200 || response.statusCode == 201) {
  final leaveType = _leaveTypes[_selectedType];
  final fromDate = _fromDate!;
  final toDate = _toDate!;
  final reason = _reasonController.text.trim();

  int totalDays = 0;
  for (DateTime day = fromDate;
      !day.isAfter(toDate);
      day = day.add(const Duration(days: 1))) {
    if (day.weekday != DateTime.sunday) totalDays++;
  }

  _resetForm();

  if (!mounted) return;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF16A34A),
                size: 44,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Application Submitted!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your leave request has been submitted successfully.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _successDetail('Leave Type', leaveType),
                  const SizedBox(height: 12),
                  _successDetail(
                    'From',
                    '${fromDate.day}/${fromDate.month}/${fromDate.year}',
                  ),
                  const SizedBox(height: 12),
                  _successDetail(
                    'To',
                    '${toDate.day}/${toDate.month}/${toDate.year}',
                  ),
                  const SizedBox(height: 12),
                  _successDetail('Total Days', '$totalDays days'),
                  const SizedBox(height: 12),
                  _successDetail('Status', 'Pending Approval'),
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _successDetail('Reason', reason),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Done',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
} else {
  debugPrint('Leave API error: ${response.statusCode} ${response.body}');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Submission failed (${response.statusCode})')),
  );
}

  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  Widget _buildAttachmentField() {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.primaryLight2),
    ),
    child: _attachedFile == null
        ? InkWell(
            onTap: _pickFile,
            child: Row(
              children: [
                Icon(
                  Icons.attach_file_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Choose PDF, image or Word document',
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                ),
                Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
          )
        : Row(
            children: [
              Icon(
                Icons.insert_drive_file_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _attachedFile!.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _attachedFile = null;
                  });
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
  );
}

}

class ApplyLeaveEmbedded extends StatelessWidget {
  final Map<String, dynamic> leaveBalance;

  const ApplyLeaveEmbedded({
    super.key,
    required this.leaveBalance,
  });

  @override
  Widget build(BuildContext context) {
    return ApplyLeaveScreen(
      leaveBalance: leaveBalance,
    );
  }
}