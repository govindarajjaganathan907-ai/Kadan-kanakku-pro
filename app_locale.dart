import 'package:flutter/material.dart';

/// Lightweight in-app localization (no codegen) supporting English & Tamil.
/// Usage: context.tr('dashboard') -> "Dashboard" or "முகப்புப் பலகை"
class AppLocale {
  static final ValueNotifier<String> languageCode = ValueNotifier('en');

  static const Map<String, Map<String, String>> _strings = {
    'app_name': {'en': 'Kadan Kanakku Pro', 'ta': 'கடன் கணக்கு புரோ'},
    'dashboard': {'en': 'Dashboard', 'ta': 'முகப்புப் பலகை'},
    'active_loans': {'en': 'Active Loans', 'ta': 'நடப்பு கடன்கள்'},
    'pending_amount': {'en': 'Pending Amount', 'ta': 'நிலுவை தொகை'},
    'todays_interest': {'en': "Today's Interest", 'ta': 'இன்றைய வட்டி'},
    'total_collected': {'en': 'Total Collected', 'ta': 'மொத்த வசூல்'},
    'add_loan': {'en': 'Add Loan', 'ta': 'கடன் சேர்க்க'},
    'customers': {'en': 'Customers', 'ta': 'வாடிக்கையாளர்கள்'},
    'reports': {'en': 'Reports', 'ta': 'அறிக்கைகள்'},
    'customer_name': {'en': 'Customer Name', 'ta': 'வாடிக்கையாளர் பெயர்'},
    'mobile_number': {'en': 'Mobile Number', 'ta': 'மொபைல் எண்'},
    'loan_amount': {'en': 'Loan Amount', 'ta': 'கடன் தொகை'},
    'interest_type': {'en': 'Interest Type', 'ta': 'வட்டி வகை'},
    'daily_interest': {'en': 'Daily Interest', 'ta': 'தினசரி வட்டி'},
    'monthly_interest': {'en': 'Monthly Interest', 'ta': 'மாத வட்டி'},
    'rate_per_lakh': {'en': 'Interest Rate per Lakh', 'ta': 'லட்சத்திற்கு வட்டி விகிதம்'},
    'loan_start_date': {'en': 'Loan Start Date', 'ta': 'கடன் தொடக்க தேதி'},
    'save': {'en': 'Save', 'ta': 'சேமி'},
    'principal_amount': {'en': 'Principal Amount', 'ta': 'அசல் தொகை'},
    'total_payable': {'en': 'Total Payable', 'ta': 'மொத்த செலுத்த வேண்டிய தொகை'},
    'add_payment': {'en': 'Add Payment', 'ta': 'பணம் செலுத்துதல் சேர்'},
    'payment_date': {'en': 'Payment Date', 'ta': 'பணம் செலுத்திய தேதி'},
    'amount_paid': {'en': 'Amount Paid', 'ta': 'செலுத்திய தொகை'},
    'payment_mode': {'en': 'Payment Mode', 'ta': 'செலுத்தும் முறை'},
    'cash': {'en': 'Cash', 'ta': 'பணம்'},
    'upi': {'en': 'UPI', 'ta': 'UPI'},
    'bank': {'en': 'Bank', 'ta': 'வங்கி'},
    'login': {'en': 'Login', 'ta': 'உள்நுழைய'},
    'enter_otp': {'en': 'Enter OTP', 'ta': 'OTP ஐ உள்ளிடவும்'},
    'verify': {'en': 'Verify', 'ta': 'சரிபார்க்க'},
    'send_otp': {'en': 'Send OTP', 'ta': 'OTP அனுப்பு'},
    'search_customer': {'en': 'Search Customer', 'ta': 'வாடிக்கையாளரைத் தேடு'},
    'closed_loans': {'en': 'Closed Loans', 'ta': 'முடிந்த கடன்கள்'},
    'daily_report': {'en': 'Daily Report', 'ta': 'தினசரி அறிக்கை'},
    'monthly_report': {'en': 'Monthly Report', 'ta': 'மாத அறிக்கை'},
    'customer_statement': {'en': 'Customer Statement', 'ta': 'வாடிக்கையாளர் அறிக்கை'},
    'export_pdf': {'en': 'Export PDF', 'ta': 'PDF ஏற்றுமதி'},
    'export_excel': {'en': 'Export Excel', 'ta': 'Excel ஏற்றுமதி'},
  };

  static String t(String key) {
    final entry = _strings[key];
    if (entry == null) return key;
    return entry[languageCode.value] ?? entry['en'] ?? key;
  }
}

extension LocaleContext on BuildContext {
  String tr(String key) => AppLocale.t(key);
}
