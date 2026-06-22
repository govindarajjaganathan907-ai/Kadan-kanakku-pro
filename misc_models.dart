import 'package:cloud_firestore/cloud_firestore.dart';

class InterestRecordModel {
  final String recordId;
  final String loanId;
  final DateTime date;
  final double interestAmount;

  InterestRecordModel({
    required this.recordId,
    required this.loanId,
    required this.date,
    required this.interestAmount,
  });

  Map<String, dynamic> toMap() => {
        'recordId': recordId,
        'loanId': loanId,
        'date': Timestamp.fromDate(date),
        'interestAmount': interestAmount,
      };

  factory InterestRecordModel.fromMap(Map<String, dynamic> map) {
    return InterestRecordModel(
      recordId: map['recordId'] ?? '',
      loanId: map['loanId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      interestAmount: (map['interestAmount'] as num).toDouble(),
    );
  }
}

class UserModel {
  final String userId;
  final String name;
  final String mobile;

  UserModel({required this.userId, required this.name, required this.mobile});

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'mobile': mobile,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      mobile: map['mobile'] ?? '',
    );
  }
}

/// Derived customer aggregation (not its own Firestore collection -
/// built on the fly from Loans where customerId/mobile matches).
class CustomerSummary {
  final String customerId;
  final String name;
  final String mobile;
  final int activeLoanCount;
  final int closedLoanCount;
  final double totalOutstanding;

  CustomerSummary({
    required this.customerId,
    required this.name,
    required this.mobile,
    required this.activeLoanCount,
    required this.closedLoanCount,
    required this.totalOutstanding,
  });
}
