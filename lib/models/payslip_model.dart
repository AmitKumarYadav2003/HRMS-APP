class PayslipSummary {
  final int id;
  final String month;
  final int year;
  final double netPay;
  final DateTime? creditedOn;

  const PayslipSummary({
    required this.id,
    required this.month,
    required this.year,
    required this.netPay,
    this.creditedOn,
  });

  factory PayslipSummary.fromJson(Map<String, dynamic> json) {
    return PayslipSummary(
      id: json['id'] as int,
      month: json['month'] as String,
      year: json['year'] as int,
      netPay: (json['net_pay'] as num).toDouble(),
      creditedOn: json['credited_on'] == null
          ? null
          : DateTime.parse(json['credited_on'] as String),
    );
  }
}

class PayslipDetail {
  final int id;
  final String month;
  final int year;
  final double basic;
  final double hra;
  final double allowance;
  final double pf;
  final double tax;
  final double gross;
  final double totalDeductions;
  final double netPay;
  final DateTime? creditedOn;

  const PayslipDetail({
    required this.id,
    required this.month,
    required this.year,
    required this.basic,
    required this.hra,
    required this.allowance,
    required this.pf,
    required this.tax,
    required this.gross,
    required this.totalDeductions,
    required this.netPay,
    this.creditedOn,
  });

  factory PayslipDetail.fromJson(Map<String, dynamic> json) {
    return PayslipDetail(
      id: json['id'] as int,
      month: json['month'] as String,
      year: json['year'] as int,
      basic: (json['basic'] as num).toDouble(),
      hra: (json['hra'] as num).toDouble(),
      allowance: (json['allowance'] as num).toDouble(),
      pf: (json['pf'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      gross: (json['gross'] as num).toDouble(),
      totalDeductions: (json['total_deductions'] as num).toDouble(),
      netPay: (json['net_pay'] as num).toDouble(),
      creditedOn: json['credited_on'] == null
          ? null
          : DateTime.parse(json['credited_on'] as String),
    );
  }
}