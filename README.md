# Kadan Kanakku Pro (கடன் கணக்கு புரோ)

A daily-interest loan tracking app for small lenders, built with Flutter + Firebase.

## Features implemented
- Mobile number OTP login (Firebase Auth)
- Dashboard: active loans, pending amount, today's interest, total collected, quick actions
- Add Loan: customer details, daily/monthly interest, ₹-per-lakh rate, live calculation preview
- Loan Details: principal, daily interest, days elapsed, accumulated interest, total payable
- Payment Entry: cash / UPI / bank, auto-updates remaining balance
- Daily interest auto-calculation: `(principal / 100000) * ratePerLakh`
- Customer management: search, active/closed tabs, loan history
- Reports: daily/monthly summaries, PDF export, Excel export, customer statement PDF
- Local notifications for daily interest reminders
- Tamil + English toggle (tap the globe icon on the dashboard)
- Light & dark theme (follows system setting)

## Project structure
```
lib/
  models/        Loan, Payment, InterestRecord, User data models
  services/      AuthService, FirestoreService, NotificationService, ExportService
  screens/       Login, Dashboard, AddLoan, LoanDetails, AddPayment, Customers, Reports
  widgets/       StatCard, QuickActionButton
  utils/         AppTheme, AppLocale (Tamil/English strings), formatters
  main.dart      App entry + Firebase init
  firebase_options.dart  PLACEHOLDER - regenerate with flutterfire CLI
```

## Setup

1. **Install Flutter** (3.19+) and the FlutterFire CLI:
   ```
   dart pub global activate flutterfire_cli
   ```

2. **Create a Firebase project** at https://console.firebase.google.com
   - Enable **Authentication → Phone** sign-in method.
   - Enable **Firestore Database** (start in production mode, then apply `firestore.rules`).
   - Enable **Cloud Messaging** if you want push notifications later.

3. **Connect Firebase to this project** (replaces the placeholder `lib/firebase_options.dart`
   and downloads `android/app/google-services.json` automatically):
   ```
   cd kadan_kanakku_pro
   flutterfire configure
   ```

4. **Install dependencies:**
   ```
   flutter pub get
   ```

5. **Run on a connected Android device/emulator:**
   ```
   flutter run
   ```

6. **Deploy Firestore rules:**
   ```
   firebase deploy --only firestore:rules
   ```

## Notes on the daily interest calculation
The core formula used throughout the app (`LoanModel.dailyInterest` in
`lib/models/loan_model.dart`):

```
dailyInterest = (principal / 100000) * ratePerLakhPerDay
```

Example from the spec: principal ₹8,00,000, rate ₹200/lakh/day →
`8 × 200 = ₹1600/day`. Over 30 days that's ₹48,000 interest, matching the
example in the requirements.

For **monthly interest** loans, the monthly rate is converted to a daily
equivalent (`monthlyInterest / 30`) so the same day-by-day accrual logic
works for both loan types.

## Production hardening checklist (not yet wired up — recommended next steps)
- Replace the debug `signingConfig` in `android/app/build.gradle` with a real
  release keystore before publishing.
- Add a scheduled **Cloud Function** (or `flutter_local_notifications` +
  WorkManager) to write `interestRecords` and fire push notifications once a
  day server-side, since a purely client-side timer won't run while the app
  is closed.
- Add server-side validation / Cloud Functions if multiple lenders will
  share one Firebase project, and scope Firestore rules by `ownerId`.
- Add the Tamil font files under `assets/fonts/NotoSansTamil-*.ttf`
  (download from Google Fonts) — referenced in `pubspec.yaml` but not
  included in this bundle due to binary size.
