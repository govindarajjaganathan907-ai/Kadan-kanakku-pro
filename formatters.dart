import 'package:intl/intl.dart';

final _formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

String formatRupees(double amount) => _formatter.format(amount);

final _dateFormatter = DateFormat('dd MMM yyyy');
String formatDate(DateTime date) => _dateFormatter.format(date);
