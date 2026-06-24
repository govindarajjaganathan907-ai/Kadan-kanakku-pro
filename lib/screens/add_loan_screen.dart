import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/loan_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_locale.dart';
import '../utils/formatters.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();

  InterestType _interestType = InterestType.daily;
  DateTime _startDate = DateTime.now();
  bool _saving = false;

  final _firestoreService = FirestoreService();

  double get _principal => double.tryParse(_amountController.text) ?? 0;
  double get _rate => double.tryParse(_rateController.text) ?? 0;

  /// Live preview of daily interest = (principal / 100000) * rate
  double get _previewDailyInterest {
    final perLakh = _principal / 100000.0;
    if (_interestType == InterestType.daily) return perLakh * _rate;
    return (perLakh * _rate) / 30.0;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final loan = LoanModel(
      loanId: const Uuid().v4(),
      customerId: const Uuid().v4(),
      customerName: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      principal: _principal,
      interestType: _interestType,
      ratePerLakh: _rate,
      startDate: _startDate,
    );

    await _firestoreService.addLoan(loan);

    setState(() => _saving = false);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('add_loan'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.tr('customer_name'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: context.tr('mobile_number'),
                prefixIcon: const Icon(Icons.phone_android),
                counterText: '',
              ),
              validator: (v) =>
                  (v == null || v.trim().length < 10) ? 'Enter valid mobile number' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.tr('loan_amount'),
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  (v == null || double.tryParse(v) == null) ? 'Enter valid amount' : null,
            ),
            const SizedBox(height: 14),
            Text(context.tr('interest_type'),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<InterestType>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('daily_interest'), style: const TextStyle(fontSize: 13)),
                    value: InterestType.daily,
                    groupValue: _interestType,
                    onChanged: (v) => setState(() => _interestType = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<InterestType>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('monthly_interest'), style: const TextStyle(fontSize: 13)),
                    value: InterestType.monthly,
                    groupValue: _interestType,
                    onChanged: (v) => setState(() => _interestType = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.tr('rate_per_lakh'),
                hintText: 'e.g. 200',
                prefixIcon: const Icon(Icons.percent),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  (v == null || double.tryParse(v) == null) ? 'Enter valid rate' : null,
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(context.tr('loan_start_date')),
              subtitle: Text(formatDate(_startDate)),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 18),
            if (_principal > 0 && _rate > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calculation Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        '${(_principal / 100000).toStringAsFixed(2)} lakh × ₹${_rate.toStringAsFixed(0)} = ${formatRupees(_previewDailyInterest)} / day'),
                    const SizedBox(height: 4),
                    Text(context.tr('daily_interest') + ': ' + formatRupees(_previewDailyInterest),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _saveLoan,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(context.tr('save')),
            ),
          ],
        ),
      ),
    );
  }
}
