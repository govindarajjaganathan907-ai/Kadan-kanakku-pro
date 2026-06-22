import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMode { cash, upi, bank }

class PaymentModel {
  final String paymentId;
  final String loanId;
  final double amount;
  final DateTime date;
  final PaymentMode mode;
  final String? note;

  PaymentModel({
    required this.paymentId,
    required this.loanId,
    required this.amount,
    required this.date,
    required this.mode,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'loanId': loanId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'paymentMode': mode.name,
      'note': note,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      paymentId: map['paymentId'] ?? '',
      loanId: map['loanId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      mode: PaymentMode.values.firstWhere(
        (m) => m.name == map['paymentMode'],
        orElse: () => PaymentMode.cash,
      ),
      note: map['note'],
    );
  }
}
