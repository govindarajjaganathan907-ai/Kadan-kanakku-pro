import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/payment_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_locale.dart';
import '../utils/formatters.dart';

class AddPaymentScreen extends StatefulWidget {
  final String loanId;
  const AddPaymentScreen({super.key, required this.loanId});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  PaymentMode _mode = PaymentMode.cash;
  bool _saving = false;

  final _firestoreService = FirestoreService();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final payment = PaymentModel(
      paymentId: const Uuid().v4(),
      loanId: widget.loanId,
      amount: double.parse(_amountController.text),
      date: _date,
      mode: _mode,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    await _firestoreService.addPayment(payment);

    setState(() => _saving = false);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('add_payment'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.tr('amount_paid'),
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
              validator: (v) =>
                  (v == null || double.tryParse(v) == null) ? 'Enter valid amount' : null,
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(context.tr('payment_date')),
              subtitle: Text(formatDate(_date)),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _pickDate,
            ),
            const SizedBox(height: 14),
            Text(context.tr('payment_mode'), style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: PaymentMode.values.map((mode) {
                final selected = _mode == mode;
                final label = mode == PaymentMode.cash
                    ? context.tr('cash')
                    : mode == PaymentMode.upi
                        ? context.tr('upi')
                        : context.tr('bank');
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _mode = mode),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _savePayment,
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
