import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/loan_model.dart';
import '../models/payment_model.dart';
import '../models/misc_models.dart';

/// Central Firestore data access layer.
/// Collections: users, loans, payments, interestRecords
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference get _loans => _db.collection('loans');
  CollectionReference get _payments => _db.collection('payments');
  CollectionReference get _interestRecords => _db.collection('interestRecords');
  CollectionReference get _users => _db.collection('users');

  // ---------------- USERS ----------------
  Future<void> upsertUser(UserModel user) async {
    await _users.doc(user.userId).set(user.toMap(), SetOptions(merge: true));
  }

  // ---------------- LOANS ----------------
  Future<String> addLoan(LoanModel loan) async {
    final id = loan.loanId.isNotEmpty ? loan.loanId : _uuid.v4();
    final newLoan = LoanModel(
      loanId: id,
      customerId: loan.customerId,
      customerName: loan.customerName,
      mobile: loan.mobile,
      principal: loan.principal,
      interestType: loan.interestType,
      ratePerLakh: loan.ratePerLakh,
      startDate: loan.startDate,
      status: loan.status,
    );
    await _loans.doc(id).set(newLoan.toMap());
    return id;
  }

  Future<void> updateLoanStatus(String loanId, LoanStatus status) async {
    await _loans.doc(loanId).update({'status': status.name});
  }

  Stream<List<LoanModel>> watchActiveLoans() {
    return _loans
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => LoanModel.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<LoanModel>> watchAllLoans() {
    return _loans
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => LoanModel.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<LoanModel>> watchLoansForCustomer(String mobile) {
    return _loans
        .where('mobile', isEqualTo: mobile)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => LoanModel.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  Future<LoanModel?> getLoan(String loanId) async {
    final doc = await _loans.doc(loanId).get();
    if (!doc.exists) return null;
    return LoanModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ---------------- PAYMENTS ----------------
  Future<void> addPayment(PaymentModel payment) async {
    final id = payment.paymentId.isNotEmpty ? payment.paymentId : _uuid.v4();
    final p = PaymentModel(
      paymentId: id,
      loanId: payment.loanId,
      amount: payment.amount,
      date: payment.date,
      mode: payment.mode,
      note: payment.note,
    );
    await _payments.doc(id).set(p.toMap());
  }

  Stream<List<PaymentModel>> watchPaymentsForLoan(String loanId) {
    return _payments
        .where('loanId', isEqualTo: loanId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PaymentModel.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  Future<double> totalPaidForLoan(String loanId) async {
    final snap = await _payments.where('loanId', isEqualTo: loanId).get();
    double total = 0;
    for (final doc in snap.docs) {
      total += (doc.data() as Map<String, dynamic>)['amount'] as num;
    }
    return total;
  }

  // ---------------- INTEREST RECORDS ----------------
  /// Writes today's interest record for a loan if not already recorded today.
  /// Called by the daily interest calculation job / on-demand check.
  Future<void> recordDailyInterestIfNeeded(LoanModel loan) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final docId = '${loan.loanId}_$dateKey';
    final existing = await _interestRecords.doc(docId).get();
    if (existing.exists) return;

    final record = InterestRecordModel(
      recordId: docId,
      loanId: loan.loanId,
      date: DateTime(today.year, today.month, today.day),
      interestAmount: loan.dailyInterest,
    );
    await _interestRecords.doc(docId).set(record.toMap());
  }

  Stream<List<InterestRecordModel>> watchInterestRecordsForLoan(String loanId) {
    return _interestRecords
        .where('loanId', isEqualTo: loanId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InterestRecordModel.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  // ---------------- DASHBOARD AGGREGATES ----------------
  Future<DashboardStats> getDashboardStats() async {
    final activeSnap = await _loans.where('status', isEqualTo: 'active').get();
    final loans = activeSnap.docs
        .map((d) => LoanModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();

    double totalPending = 0;
    double todaysInterest = 0;
    for (final loan in loans) {
      final paid = await totalPaidForLoan(loan.loanId);
      final payable = loan.totalPayable() - paid;
      totalPending += payable > 0 ? payable : 0;
      todaysInterest += loan.dailyInterest;
    }

    final paymentsSnap = await _payments.get();
    double totalCollected = 0;
    for (final doc in paymentsSnap.docs) {
      totalCollected += (doc.data() as Map<String, dynamic>)['amount'] as num;
    }

    return DashboardStats(
      activeLoanCount: loans.length,
      totalPendingAmount: totalPending,
      todaysInterestTotal: todaysInterest,
      totalCollectedAmount: totalCollected,
    );
  }
}

class DashboardStats {
  final int activeLoanCount;
  final double totalPendingAmount;
  final double todaysInterestTotal;
  final double totalCollectedAmount;

  DashboardStats({
    required this.activeLoanCount,
    required this.totalPendingAmount,
    required this.todaysInterestTotal,
    required this.totalCollectedAmount,
  });
}
