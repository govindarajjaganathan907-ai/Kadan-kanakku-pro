import 'package:flutter/material.dart';
import '../models/loan_model.dart';
import '../models/payment_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_locale.dart';
import '../utils/formatters.dart';
import 'add_payment_screen.dart';

class LoanDetailsScreen extends StatefulWidget {
  final String loanId;
  const LoanDetailsScreen({super.key, required this.loanId});

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  final _firestoreService = FirestoreService();
  LoanModel? _loan;
  double _totalPaid = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loan = await _firestoreService.getLoan(widget.loanId);
    final paid = await _firestoreService.totalPaidForLoan(widget.loanId);
    setState(() {
      _loan = loan;
      _totalPaid = paid;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final loan = _loan;
    if (loan == null) {
      return const Scaffold(body: Center(child: Text('Loan not found')));
    }

    final balance = loan.totalPayable() - _totalPaid;

    return Scaffold(
      appBar: AppBar(title: Text(loan.customerName)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                          child: Text(
                            loan.customerName.isNotEmpty
                                ? loan.customerName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                                fontSize: 20, color: Theme.of(context).primaryColor),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loan.customerName,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(loan.mobile, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: loan.status == LoanStatus.active
                                ? Colors.green.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            loan.status.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: loan.status == LoanStatus.active
                                  ? Colors.green.shade800
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    _detailRow(context.tr('principal_amount'), formatRupees(loan.principal)),
                    _detailRow(context.tr('daily_interest'), formatRupees(loan.dailyInterest)),
                    _detailRow('Days Elapsed', '${loan.daysElapsed()} days'),
                    _detailRow('Accumulated Interest', formatRupees(loan.totalInterest())),
                    _detailRow('Total Paid', formatRupees(_totalPaid)),
                    const Divider(height: 20),
                    _detailRow(
                      context.tr('total_payable'),
                      formatRupees(balance > 0 ? balance : 0),
                      bold: true,
                      color: balance > 0 ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(context.tr('add_payment')),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddPaymentScreen(loanId: loan.loanId),
                        ),
                      );
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(
                      loan.status == LoanStatus.active
                          ? Icons.lock_outline
                          : Icons.lock_open_outlined,
                    ),
                    label: Text(loan.status == LoanStatus.active ? 'Close Loan' : 'Reopen'),
                    onPressed: () async {
                      final newStatus = loan.status == LoanStatus.active
                          ? LoanStatus.closed
                          : LoanStatus.active;
                      await _firestoreService.updateLoanStatus(loan.loanId, newStatus);
                      _load();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Payment History',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            StreamBuilder<List<PaymentModel>>(
              stream: _firestoreService.watchPaymentsForLoan(loan.loanId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final payments = snapshot.data!;
                if (payments.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No payments recorded yet.'),
                  );
                }
                return Column(
                  children: payments.map((p) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(0.15),
                          child: const Icon(Icons.arrow_downward, color: Colors.green),
                        ),
                        title: Text(formatRupees(p.amount),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(formatDate(p.date)),
                        trailing: Chip(label: Text(p.mode.name.toUpperCase())),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: bold ? 17 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
