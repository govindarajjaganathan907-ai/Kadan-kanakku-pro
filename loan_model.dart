import 'package:cloud_firestore/cloud_firestore.dart';

enum InterestType { daily, monthly }
enum LoanStatus { active, closed }

/// Core Loan model.
/// Interest formula (per business rule):
///   dailyInterest = (principal / 100000) * ratePerLakhPerDay
/// Example: principal = 800000, ratePerLakhPerDay = 200
///          dailyInterest = (800000/100000) * 200 = 8 * 200 = 1600
class LoanModel {
  final String loanId;
  final String customerId;
  final String customerName;
  final String mobile;
  final double principal;
  final InterestType interestType;
  final double ratePerLakh; // per day if daily, per month if monthly
  final DateTime startDate;
  final LoanStatus status;
  final DateTime createdAt;
  final String? notes;

  LoanModel({
    required this.loanId,
    required this.customerId,
    required this.customerName,
    required this.mobile,
    required this.principal,
    required this.interestType,
    required this.ratePerLakh,
    required this.startDate,
    this.status = LoanStatus.active,
    DateTime? createdAt,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Daily interest amount in rupees.
  double get dailyInterest {
    final perLakh = principal / 100000.0;
    if (interestType == InterestType.daily) {
      return perLakh * ratePerLakh;
    }
    // Monthly rate converted to a daily equivalent (rate per lakh per month / 30)
    return (perLakh * ratePerLakh) / 30.0;
  }

  /// Number of days elapsed since loan start (minimum 0).
  int daysElapsed({DateTime? asOf}) {
    final now = asOf ?? DateTime.now();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(start).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Total interest accumulated as of a given date (defaults to today).
  double totalInterest({DateTime? asOf}) {
    return dailyInterest * daysElapsed(asOf: asOf);
  }

  /// Total payable = principal + accumulated interest.
  double totalPayable({DateTime? asOf}) {
    return principal + totalInterest(asOf: asOf);
  }

  Map<String, dynamic> toMap() {
    return {
      'loanId': loanId,
      'customerId': customerId,
      'customerName': customerName,
      'mobile': mobile,
      'amount': principal,
      'interestType': interestType.name,
      'interestRate': ratePerLakh,
      'startDate': Timestamp.fromDate(startDate),
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      loanId: map['loanId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      mobile: map['mobile'] ?? '',
      principal: (map['amount'] as num).toDouble(),
      interestType: (map['interestType'] == 'monthly')
          ? InterestType.monthly
          : InterestType.daily,
      ratePerLakh: (map['interestRate'] as num).toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      status: (map['status'] == 'closed') ? LoanStatus.closed : LoanStatus.active,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
    );
  }

  LoanModel copyWith({LoanStatus? status}) {
    return LoanModel(
      loanId: loanId,
      customerId: customerId,
      customerName: customerName,
      mobile: mobile,
      principal: principal,
      interestType: interestType,
      ratePerLakh: ratePerLakh,
      startDate: startDate,
      status: status ?? this.status,
      createdAt: createdAt,
      notes: notes,
    );
  }
}
