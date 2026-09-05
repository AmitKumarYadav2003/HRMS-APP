import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class PayslipScreen extends StatefulWidget {
  const PayslipScreen({super.key});

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  Map<String, dynamic>? _selectedPayslip;

  final List<Map<String, dynamic>> _payslips = [
    {
      'month': 'August 2026',
      'net': '₹68,500',
      'date': '30 Aug 2026',
      'basic': '₹45,000',
      'hra': '₹18,000',
      'allowance': '₹8,000',
      'pf': '₹2,000',
      'tax': '₹500',
    },
    {
      'month': 'July 2026',
      'net': '₹68,500',
      'date': '30 Jul 2026',
      'basic': '₹45,000',
      'hra': '₹18,000',
      'allowance': '₹8,000',
      'pf': '₹2,000',
      'tax': '₹500',
    },
    {
      'month': 'June 2026',
      'net': '₹67,900',
      'date': '30 Jun 2026',
      'basic': '₹45,000',
      'hra': '₹18,000',
      'allowance': '₹7,400',
      'pf': '₹2,000',
      'tax': '₹500',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _selectedPayslip == null ? _buildList() : _buildDetail(),
      ),
    );
  }

  Widget _buildList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          _buildHeader('Payslips', () => Navigator.pop(context)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryLight2,
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest Net Pay',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _payslips[0]['net'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'History',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          ..._payslips.map(
            (p) => GestureDetector(
              onTap: () => setState(() => _selectedPayslip = p),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryDark, size: 19)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['month'],
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Credited ${p['date']}',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          p['net'],
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Paid',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetail() {
    final p = _selectedPayslip!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          _buildHeader(
            p['month'],
            () => setState(() => _selectedPayslip = null),
          ),
          const SizedBox(height: 20),
          Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight2.withOpacity(0.75)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
    borderRadius: BorderRadius.circular(18),
    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 18, offset: const Offset(0, 8))],
  ),
  child: Column(
    children: [
      Text('NET PAY', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.75), fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1)),
      const SizedBox(height: 6),
      Text(p['net'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text('Credited on ${p['date']}', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.75), fontSize: 11)),
    ],
  ),
),
          const SizedBox(height: 20),
          _buildBreakdownCard(
            'Earnings',
            const Color(0xFF10B981),
            Icons.trending_up_rounded,
            [
              {'label': 'Basic', 'value': p['basic']},
              {'label': 'HRA', 'value': p['hra']},
              {'label': 'Allowance', 'value': p['allowance']},
            ],
          ),
          const SizedBox(height: 14),
          _buildBreakdownCard(
            'Deductions',
            const Color(0xFFEF4444),
            Icons.trending_down_rounded,
            [
              {'label': 'PF', 'value': p['pf']},
              {'label': 'Tax', 'value': p['tax']},
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.download_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                'Download PDF',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, VoidCallback onBack) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
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
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownCard(
    String title,
    Color color,
    IconData icon,
    List<Map<String, String>> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 15),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    item['value']!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
