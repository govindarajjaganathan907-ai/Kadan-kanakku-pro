import 'package:flutter/material.dart';
import '../models/loan_model.dart';
import '../services/firestore_service.dart';
import '../services/export_service.dart';
import '../utils/app_locale.dart';
import '../utils/formatters.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _firestoreService = FirestoreService();
  bool _exporting = false;

  Future<List<LoanModel>> _activeLoans() async {
    final snap = await _firestoreService.watchActiveLoans().first;
    return snap;
  }

  Future<void> _export({required bool asPdf, required bool monthly}) async {
    setState(() => _exporting = true);
    try {
      final loans = await _activeLoans();
      final title = monthly ? context.tr('monthly_report') : context.tr('daily_report');
      if (asPdf) {
        await ExportService.exportLoansToPdf(title: title, loans: loans);
      } else {
        await ExportService.exportLoansToExcel(title: title, loans: loans);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('reports'))),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FutureBuilder<List<LoanModel>>(
                future: _activeLoans(),
                builder: (context, snapshot) {
                  final loans = snapshot.data ?? [];
                  final totalPrincipal = loans.fold<double>(0, (s, l) => s + l.principal);
                  final totalDailyInterest =
                      loans.fold<double>(0, (s, l) => s + l.dailyInterest);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Summary', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          Text('Active Loans: ${loans.length}'),
                          Text('Total Principal: ${formatRupees(totalPrincipal)}'),
                          Text('Total Daily Interest: ${formatRupees(totalDailyInterest)}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _reportTile(
                title: context.tr('daily_report'),
                subtitle: 'Today\'s active loans & interest snapshot',
                icon: Icons.today_outlined,
                onPdf: () => _export(asPdf: true, monthly: false),
                onExcel: () => _export(asPdf: false, monthly: false),
              ),
              const SizedBox(height: 12),
              _reportTile(
                title: context.tr('monthly_report'),
                subtitle: 'Full monthly overview of loans & interest',
                icon: Icons.calendar_month_outlined,
                onPdf: () => _export(asPdf: true, monthly: true),
                onExcel: () => _export(asPdf: false, monthly: true),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text(context.tr('customer_statement')),
                  subtitle: const Text('Open a customer\'s loan to generate their statement'),
                ),
              ),
            ],
          ),
          if (_exporting)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _reportTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPdf,
    required VoidCallback onExcel,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(context.tr('export_pdf')),
                    onPressed: onPdf,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.table_chart_outlined),
                    label: Text(context.tr('export_excel')),
                    onPressed: onExcel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
