import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../utils/app_locale.dart';
import '../utils/formatters.dart';
import '../widgets/stat_card.dart';
import 'add_loan_screen.dart';
import 'customers_screen.dart';
import 'reports_screen.dart';
import 'loan_details_screen.dart';
import '../models/loan_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firestoreService = FirestoreService();
  DashboardStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final stats = await _firestoreService.getDashboardStats();
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('app_name')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              AppLocale.languageCode.value =
                  AppLocale.languageCode.value == 'en' ? 'ta' : 'en';
              setState(() {});
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.6,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          title: context.tr('active_loans'),
                          value: '${_stats?.activeLoanCount ?? 0}',
                          icon: Icons.account_balance_rounded,
                          color: Colors.blue,
                        ),
                        StatCard(
                          title: context.tr('pending_amount'),
                          value: formatRupees(_stats?.totalPendingAmount ?? 0),
                          icon: Icons.pending_actions_rounded,
                          color: Colors.orange,
                        ),
                        StatCard(
                          title: context.tr('todays_interest'),
                          value: formatRupees(_stats?.todaysInterestTotal ?? 0),
                          icon: Icons.trending_up_rounded,
                          color: Colors.purple,
                        ),
                        StatCard(
                          title: context.tr('total_collected'),
                          value: formatRupees(_stats?.totalCollectedAmount ?? 0),
                          icon: Icons.savings_rounded,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Quick Actions',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: QuickActionButton(
                            label: context.tr('add_loan'),
                            icon: Icons.add_circle_outline,
                            color: Colors.green.shade700,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddLoanScreen()),
                              );
                              _loadStats();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuickActionButton(
                            label: context.tr('customers'),
                            icon: Icons.people_alt_outlined,
                            color: Colors.blue.shade700,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CustomersScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuickActionButton(
                            label: context.tr('reports'),
                            icon: Icons.bar_chart_rounded,
                            color: Colors.purple.shade700,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ReportsScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Recent Loans',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    StreamBuilder<List<LoanModel>>(
                      stream: _firestoreService.watchActiveLoans(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final loans = snapshot.data!.take(5).toList();
                        if (loans.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: Text('No active loans yet.')),
                          );
                        }
                        return Column(
                          children: loans.map((loan) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor.withOpacity(0.15),
                                  child: Text(
                                    loan.customerName.isNotEmpty
                                        ? loan.customerName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                title: Text(loan.customerName,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                    'Daily Interest: ${formatRupees(loan.dailyInterest)}'),
                                trailing: Text(formatRupees(loan.totalPayable()),
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoanDetailsScreen(loanId: loan.loanId),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddLoanScreen()),
          );
          _loadStats();
        },
        icon: const Icon(Icons.add),
        label: Text(context.tr('add_loan')),
      ),
    );
  }
}
