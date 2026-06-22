import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/loan_model.dart';
import '../models/payment_model.dart';

/// Builds PDF / Excel reports for daily reports, monthly reports
/// and individual customer statements, then shares the resulting file.
class ExportService {
  /// Generic loan list PDF (used for Daily Report / Monthly Report).
  static Future<File> exportLoansToPdf({
    required String title,
    required List<LoanModel> loans,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: title),
          pw.Table.fromTextArray(
            headers: ['Customer', 'Mobile', 'Principal', 'Daily Interest', 'Days', 'Payable'],
            data: loans.map((l) {
              return [
                l.customerName,
                l.mobile,
                l.principal.toStringAsFixed(0),
                l.dailyInterest.toStringAsFixed(0),
                l.daysElapsed().toString(),
                l.totalPayable().toStringAsFixed(0),
              ];
            }).toList(),
          ),
        ],
      ),
    );
    return _saveAndShare(await doc.save(), '$title.pdf');
  }

  /// Customer statement PDF combining loan + payment history.
  static Future<File> exportCustomerStatementPdf({
    required LoanModel loan,
    required List<PaymentModel> payments,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'Customer Statement - ${loan.customerName}'),
          pw.Paragraph(text: 'Mobile: ${loan.mobile}'),
          pw.Paragraph(text: 'Principal: ₹${loan.principal.toStringAsFixed(0)}'),
          pw.Paragraph(text: 'Daily Interest: ₹${loan.dailyInterest.toStringAsFixed(0)}'),
          pw.Paragraph(text: 'Days Elapsed: ${loan.daysElapsed()}'),
          pw.Paragraph(text: 'Total Payable: ₹${loan.totalPayable().toStringAsFixed(0)}'),
          pw.SizedBox(height: 12),
          pw.Header(level: 1, text: 'Payment History'),
          pw.Table.fromTextArray(
            headers: ['Date', 'Amount', 'Mode'],
            data: payments
                .map((p) => [
                      '${p.date.day}/${p.date.month}/${p.date.year}',
                      p.amount.toStringAsFixed(0),
                      p.mode.name.toUpperCase(),
                    ])
                .toList(),
          ),
        ],
      ),
    );
    return _saveAndShare(await doc.save(), 'Statement_${loan.customerName}.pdf');
  }

  /// Excel export of loans (Daily/Monthly Report).
  static Future<File> exportLoansToExcel({
    required String title,
    required List<LoanModel> loans,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Report'];
    sheet.appendRow([
      TextCellValue('Customer'),
      TextCellValue('Mobile'),
      TextCellValue('Principal'),
      TextCellValue('Daily Interest'),
      TextCellValue('Days'),
      TextCellValue('Payable'),
    ]);
    for (final l in loans) {
      sheet.appendRow([
        TextCellValue(l.customerName),
        TextCellValue(l.mobile),
        DoubleCellValue(l.principal),
        DoubleCellValue(l.dailyInterest),
        IntCellValue(l.daysElapsed()),
        DoubleCellValue(l.totalPayable()),
      ]);
    }
    final bytes = excel.encode()!;
    return _saveAndShare(bytes, '$title.xlsx');
  }

  static Future<File> _saveAndShare(List<int> bytes, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: filename);
    return file;
  }
}
