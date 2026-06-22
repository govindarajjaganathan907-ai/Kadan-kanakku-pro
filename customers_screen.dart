import 'package:flutter/material.dart';
import '../models/loan_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_locale.dart';
import '../utils/formatters.dart';
import 'loan_details_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen>
    with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  String _query = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('customers')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: context.tr('active_loans')),
            Tab(text: context.tr('closed_loans')),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.tr('search_customer'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _loanList(LoanStatus.active),
                _loanList(LoanStatus.closed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loanList(LoanStatus status) {
    return StreamBuilder<List<LoanModel>>(
      stream: _firestoreService.watchAllLoans(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var loans = snapshot.data!.where((l) => l.status == status).toList();
        if (_query.isNotEmpty) {
          loans = loans
              .where((l) =>
                  l.customerName.toLowerCase().contains(_query) ||
                  l.mobile.contains(_query))
              .toList();
        }
        if (loans.isEmpty) {
          return const Center(child: Text('No customers found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: loans.length,
          itemBuilder: (context, index) {
            final loan = loans[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                  child: Text(
                    loan.customerName.isNotEmpty ? loan.customerName[0].toUpperCase() : '?',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                title: Text(loan.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(loan.mobile),
                trailing: Text(
                  formatRupees(loan.totalPayable()),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoanDetailsScreen(loanId: loan.loanId)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
